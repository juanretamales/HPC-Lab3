/*
Integrantes: Juan Retamales
*/


//#include <pmmintrin.h>

/*C library to perform Input/Output operations*/
#include <stdio.h>
/*C  library Añade funciones para convertir texto a otro formato*/
#include <stdlib.h>
#include <ctype.h>
#include <fcntl.h>

/*Libreria C para trabajar y comparar texto (de la linea de comando)*/
#include <string.h>
/* Librerias para open y write*/
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <math.h>

//incluyendo openMP
//#ifdef _OPENMP
//#include <omp.h>
//#endif

#include <time.h>

/* NOTAS
Para compilar: nvcc wave.cu -o wave.o
Para compilar2: nvcc wave.cu -o wave -lm -arch=sm_52
Para ejecutar: ./wave.o -N 256 -X 256 -Y 256 -T 100 -f salidaGrilla.raw -t 100

para probar: time ./wave.o -N 256 -X 128 -Y 128 -T 100 -f salidaGrilla.raw -t 26 > test.log


para enviar al servidor: scp code.cu jretamales@bioserver.diinf.usach.cl:/alumnos/jretamales/lab2
*/
__global__ void next(float *c_gt, float *c_gt1, float *c_gt2, int size, int t){
	int blockD = blockDim.x;
	int blockX = blockIdx.x;
	int threadX = threadIdx.x;

	//int ix = blockX * blockD + threadX;
	//if(i < values)
	//	c[i] = a[i] + b[i];
	int position = threadIdx.x + blockDim.x * blockIdx.x;
	printf("Hello Im X thread %d in block %d of %d threads and position global[%d] \n", threadX, blockX, blockD, position);
	 blockD = blockDim.y;
	 blockX = blockIdx.y;
	 threadX = threadIdx.y;
	 position = threadIdx.y + blockDim.y * blockIdx.y;
	printf("Hello Im Y thread %d in block %d of %d threads and position global[%d] \n", threadX, blockX, blockD, position);

	    float dt=0.1;
    	float dd=2.0;
    	float c=1.0;

	for(int i = 0; i<size; i++)
	{
		for(int j = 0; j<size; j++)
		{
			//para tiempo t==0
			if(t==0)
			{
				//verificacion para condicion inicial
				if((0.4*size)<i && (0.4*size)<j && i<(0.6*size) && j<(0.6*size))
				{
					c_gt[size*i+j]=20;
				}
				else
				{
					c_gt[size*i+j]=0;
				}
			}//fin if  t==0
			else
			{
				if(t==1)
				{
					if(i!=0 && j!=0 && i!=(size-1) && j!=(size-1))//verificando condion de borde
					{
						//ecuacion de Schroedinger para t=1
						c_gt[size*i+j] = c_gt1[size*i+j]+(pow(c,2)/2)*(pow((dt/dd),2))*(c_gt1[size*(i+1)+j]+c_gt1[size*(i-1)+j]+c_gt1[size*(i)+(j-1)]+c_gt1[size*(i)+(j+1)]-4*c_gt1[size*i+j]);
					}
					else
					{
						c_gt[size*i+j] = 0;
					}
				}//fin if  t==1
				else
				{// si t es mayor a 1
					if(i!=0 && j!=0 && i!=(size-1) && j!=(size-1))//verificando condion de borde
					{
						//ecuacion de Schroedinger para t>1
						c_gt[size*i+j] = 2*c_gt1[size*i+j]-c_gt2[size*i+j]+(pow(c,2))*(pow((dt/dd),2))*(c_gt1[size*(i+1)+j]+c_gt1[size*(i-1)+j]+c_gt1[size*(i)+(j-1)]+c_gt1[size*(i)+(j+1)]-4*c_gt1[size*i+j]);

					}
					else
					{
						c_gt[size*i+j] = 0;
					}
				}//fin if  t==1 else
			}//fin if  t==0 else
		}//fin for j
	}//fin for i
}

__global__ void next2(float *c_gt, float *c_gt1, float *c_gt2, int size, int t){
	int blockD = blockDim.x;
	int blockX = blockIdx.x;
	int threadX = threadIdx.x;

	//int ix = blockX * blockD + threadX;
	//if(i < values)
	//	c[i] = a[i] + b[i];
	printf("Hello Im thread %d in block %d of %d threads\n", threadX, blockX, blockD);

	    float dt=0.1;
    	float dd=2.0;
    	float c=1.0;

	for(int i = 0; i<size; i++)
	{
		for(int j = 0; j<size; j++)
		{
			//para tiempo t==0
			if(t==0)
			{
				//verificacion para condicion inicial
				if((0.4*size)<i && (0.4*size)<j && i<(0.6*size) && j<(0.6*size))
				{
					c_gt[size*i+j]=20;
				}
				else
				{
					c_gt[size*i+j]=0;
				}
			}//fin if  t==0
			else
			{
				if(t==1)
				{
					if(i!=0 && j!=0 && i!=(size-1) && j!=(size-1))//verificando condion de borde
					{
						//ecuacion de Schroedinger para t=1
						c_gt[size*i+j] = c_gt1[size*i+j]+(pow(c,2)/2)*(pow((dt/dd),2))*(c_gt1[size*(i+1)+j]+c_gt1[size*(i-1)+j]+c_gt1[size*(i)+(j-1)]+c_gt1[size*(i)+(j+1)]-4*c_gt1[size*i+j]);
					}
					else
					{
						c_gt[size*i+j] = 0;
					}
				}//fin if  t==1
				else
				{// si t es mayor a 1
					if(i!=0 && j!=0 && i!=(size-1) && j!=(size-1))//verificando condion de borde
					{
						//ecuacion de Schroedinger para t>1
						c_gt[size*i+j] = 2*c_gt1[size*i+j]-c_gt2[size*i+j]+(pow(c,2))*(pow((dt/dd),2))*(c_gt1[size*(i+1)+j]+c_gt1[size*(i-1)+j]+c_gt1[size*(i)+(j-1)]+c_gt1[size*(i)+(j+1)]-4*c_gt1[size*i+j]);

					}
					else
					{
						c_gt[size*i+j] = 0;
					}
				}//fin if  t==1 else
			}//fin if  t==0 else
		}//fin for j
	}//fin for i
}

__global__ void copyT1T(float *c_gt, float *c_gt1, int size){
	printf("\nCopianto T a T1");
	for(int i=0;i<size;i++)
	{
		for(int j=0;j<size;j++)
		{
			c_gt1[size*i+j]=c_gt[size*i+j];
		}
	}
}

__global__ void copyT2T1(float *c_gt1, float *c_gt2, int size){
	printf("\nCopianto T1 a T2");
	for(int i=0;i<size;i++)
	{
		for(int j=0;j<size;j++)
		{
			c_gt2[size*i+j]=c_gt1[size*i+j];
		}
	}
}


/*
 * Function principal encargada de recibir y gestionar los datos recibidos
 */
 int main(int argc, char *argv[])
 {
   /*Variables int guardan el archivo de salida */
   int outputF;
    /*Variables int guardan el archivo de entrada y salida respectivamente*/
    int tamanoGrilla = 0;
    int num_pasos = 0;
    int iteracionSalida = 0;
int tamanoBlockX = 0;
int tamanoBlockY = 0;

    int t, j, i;



    //creo las variables para ver el tiempo transcurrido
    clock_t start_t, end_t, total_t;
	start_t = clock();



    /*De tener menos de 5 elementos por parametros se cancela ya que es insuficiente para iniciar*/
    if (argc<4)
    {
        perror("se esperaban mas parametros...\n");
        return 0;
    }

    /*Se crea un loop para revisar los parametros recibidos por consola, como argc[0] es el nombre del ejecutable, se inicia en 1 para revisar del primer parametro*/
    for(int i=1; i<argc;i++)
    {
      if(strcmp(argv[i],"-N")==0)
      {
        /*Se verifica que el argumento posterior a -N sea un numero*/
        tamanoGrilla=atoi(argv[i+1]);
      }
	if(strcmp(argv[i],"-X")==0)
      {
        /*Se verifica que el argumento posterior a -X sea un numero*/
        tamanoBlockX=atoi(argv[i+1]);
      }
	if(strcmp(argv[i],"-Y")==0)
      {
        /*Se verifica que el argumento posterior a -Y sea un numero*/
        tamanoBlockY=atoi(argv[i+1]);
      }

      if(strcmp(argv[i],"-T")==0)
      {
        /*Se verifica que el argumento posterior a -T sea un numero*/
        num_pasos=atoi(argv[i+1]);
      }


      if(strcmp(argv[i],"-f")==0  )
      {
        /*Se verifica que el argumento posterior abriendo o creando el archivo*/
        outputF=open(argv[i+1], O_CREAT | O_WRONLY, 0600);
        if(outputF == -1)
        {
          perror("\nFailed to create an open the file.");
          //EXIT_FAILURE;
          exit(1);
        }
      }
      if(strcmp(argv[i],"-t")==0)
      {
        /*Se verifica que el argumento posterior a -t sea un numero*/
        iteracionSalida=atoi(argv[i+1]);
      }
    }/*Fin loop*/



    /*Se comprueba si llegaron todos los parametros obligatorios*/
    if(outputF != -1 && tamanoGrilla>0  && iteracionSalida>0)
    {

			dim3 numBlocks (tamanoBlockX, tamanoBlockY);//asigno el blocksize


			dim3 blocksize (tamanoGrilla / tamanoBlockX, tamanoGrilla / tamanoBlockY);


			//float grillaT2[tamanoGrilla][tamanoGrilla];//grilla en tiempo (t-2)

			//float grillaT1[tamanoGrilla][tamanoGrilla];//Grilla en tiempo (t-1)

			//float grilla[tamanoGrilla][tamanoGrilla]; //grilla en tiempo (t) actual

			float *grillaT2 = (float*)malloc(tamanoGrilla*tamanoGrilla*sizeof(float));//grilla en tiempo (t-2)
			float *grillaT1 = (float*)malloc(tamanoGrilla*tamanoGrilla*sizeof(float));//Grilla en tiempo (t-1)
			float *grilla = (float*)malloc(tamanoGrilla*tamanoGrilla*sizeof(float));//grilla en tiempo (t) actual

			float *c_gt2, *c_gt1, *c_gt;//todas las grilla cuda se guardan aqui
			cudaMalloc((void**) &c_gt2, tamanoGrilla*tamanoGrilla*sizeof(float));//grilla cuda en tiempo (t-2)
			cudaMalloc((void**) &c_gt1, tamanoGrilla*tamanoGrilla*sizeof(float));//Grilla cuda en tiempo (t-1)
			cudaMalloc((void**) &c_gt, tamanoGrilla*tamanoGrilla*sizeof(float));//grilla cuda en tiempo (t) actual

			//copiando arreglos desde el host al device
			cudaMemcpy(c_gt2, grillaT2, tamanoGrilla*tamanoGrilla*sizeof(float), cudaMemcpyHostToDevice);
			cudaMemcpy(c_gt1, grillaT1, tamanoGrilla*tamanoGrilla*sizeof(float), cudaMemcpyHostToDevice);
			cudaMemcpy(c_gt, grilla, tamanoGrilla*tamanoGrilla*sizeof(float), cudaMemcpyHostToDevice);

			for( t=0;t<num_pasos;t++)
			{
				printf("\n   usando t=%d \n", t);
				//al final de la iteracion la grillaT1 de tiempo (t-1) pasa a ser grillaT2 que corresponde a grilla en tiempo (t-2)
				//asigno num_hebras como numero de hebras para el siguiente bloque, y asigno cuales variables son compartidas y privadas.
				next<<<numBlocks,blocksize>>>(c_gt, c_gt1, c_gt2, tamanoGrilla, t);
				cudaDeviceSynchronize();
				//copiando arreglos desde el device al host
				cudaMemcpy(c_gt, grilla, tamanoGrilla*sizeof(float), cudaMemcpyDeviceToHost);

				//si iteracion de salida es igual al al tiempo (t) la recorro sin paralelismo e imprimo
				if(t==(iteracionSalida-1))
				{
					for( i=0;i<tamanoGrilla;i++)
					{

						for( j=0;j<tamanoGrilla;j++)
						{

							printf("\n   intentando guardar %f", grilla[tamanoGrilla*i+j]);
							write(outputF, &grilla[tamanoGrilla*i+j] , sizeof(float));
						}
					}
				}



				//al final de la iteracion la grillaT1 de tiempo (t-1) pasa a ser grillaT2 que corresponde a grilla en tiempo (t-2)
				//asigno num_hebras como numero de hebras para el siguiente bloque, y asigno cuales variables son compartidas y privadas.
        copyT2T1<<<numBlocks,blocksize>>>(c_gt1, c_gt2, tamanoGrilla);
				cudaDeviceSynchronize();//sincronizo los datos
				cudaMemcpy(c_gt2, c_gt1, tamanoGrilla*tamanoGrilla*sizeof(float), cudaMemcpyDeviceToHost);
        //al final de la iteracion la grilla de tiempo (t) pasa a ser grillaT1 que corresponde a grilla en tiempo (t-1)
				//asigno num_hebras como numero de hebras para el siguiente bloque, y asigno cuales variables son compartidas y privadas.
        copyT1T<<<numBlocks,blocksize>>>(c_gt, c_gt1, tamanoGrilla);
				cudaDeviceSynchronize();//sincronizo los datos
				//copiando arreglos desde el device al host
				cudaMemcpy(c_gt, grilla, tamanoGrilla*tamanoGrilla*sizeof(float), cudaMemcpyDeviceToHost);


      }//fin for t

			cudaFree(c_gt2);
			cudaFree(c_gt1);
			cudaFree(c_gt);

      close (outputF);

	  //descomentar si se desea ver el tiempo empleado
      //printf("Tiempo usado con  Tamano[%d] num_Pasos[%d]  Salida[%d] = %f sec.\n", tamanoGrilla, num_pasos, iteracionSalida, end-start);
	end_t = clock();
	total_t = (double)(end_t - start_t) / CLOCKS_PER_SEC;
   	printf("Total time taken by CPU: %f\n", (double)total_t  );
      return 0;
    }//fin if principal
  }//fin main
