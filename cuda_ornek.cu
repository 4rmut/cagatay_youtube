#include <iostream>
#include <numeric>
#include <cstdlib>

// Kolayl�k olsun
using namespace std;

// Tipik bir C++ fonksiyonu 
void carp(int n, float *x, float *y, float *z)
{
  for (int i = 0; i < n; i++)
  {
      z[i] = x[i] * y[i];
  }   
}


// �stteki fonksiyonun CUDA versiyonu
__global__
void carp_cuda(int n, float *x, float *y, float *z)
{
  for (int i = threadIdx.x; i < n; i += blockDim.x)
  {
      z[i] = x[i] * y[i];
  }       
}

int main(int argc, char *argv[])
{
  // �ok b�y�k bir say� belirleyelim
  int N = 10000;

  float *x_gpu, *y_gpu, *z_gpu, *x_cpu, *y_cpu, *z_cpu;

  // GPU ve CPU taraf�ndan ula�al�bilen memory ay�rtal�m
  cudaMallocManaged(&x_gpu, N * sizeof(float));
  cudaMallocManaged(&y_gpu, N * sizeof(float));
  cudaMallocManaged(&z_gpu, N * sizeof(float));

  // Sadece CPU taraf�ndan ula��labilen memory ay�rtal�m
  x_cpu = new float[N];
  y_cpu = new float[N];
  z_cpu = new float[N];

  // 
  for (int i = 0; i < N; ++i) {
    x_gpu[i] = 1.0f;
    y_gpu[i] = 2.0f;
    x_cpu[i] = 1.0f;
    y_cpu[i] = 2.0f;
  }

  // Fonksiyonu GPU'da argv[1] blokta ve her blokta argv[2] thread
  // olacak �ekilde �a��ral�m
  int blok_sayisi = atoi(argv[1]);
  int thread_sayisi = atoi(argv[2]);

  carp_cuda<<<blok_sayisi, thread_sayisi>>>(N, x_gpu, y_gpu, z_gpu);

  // GPU'yu bekleyelim de i�ini bitirsin, yoksa ortam kar���r.
  cudaDeviceSynchronize();

  // Normal CPU fonsiyonunu �a��ral�m
  carp(N, x_cpu, y_cpu, z_cpu);

  // Bakal�m do�ru mu yapt�k?
  // z_gpu ve z_cpu ayn� de�erlere sahip olmas� laz�m 
  for(int i = 0; i < N; ++i) 
      cout << z_cpu[i] << " " << z_gpu[i] << endl;

  // Release the Kraken - Kraken'� sal�verin gelsin. 
  cudaFree(x_gpu);
  cudaFree(y_gpu);
  cudaFree(z_gpu);
  delete [] x_cpu;
  delete [] y_cpu;
  delete [] z_cpu;
  
  return 0;
}

