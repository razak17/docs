#include <stdio.h>
#include <vector>

void swap(int *a, int *b) {
  int temp = *a;
  *a = *b;
  *b = temp;
}

void printArray(int arr[], int n) {
  int i = 0;
  printf("The sorted array is \n");
  for (i = 0; i < n; i++) {
    printf("%d\n", arr[i]);
  }
}

void bubbleSort(int arr[], int n) {
  int i = 0;
  int j = 0;
  for (i = 0; i < n - 1; i++) {
    for (j = 0; j < n - i - 1; j++) {
      if (arr[j] > arr[j + 1]) {
        swap(&arr[j], &arr[j + 1]);
      }
    }
    printArray(arr, n);
  }
}

int main(int argc, const char **argv) {
  int n = 5;
  int arr[99] = {5, 9, 3, 7, 2};
  bubbleSort(arr, n);
  printArray(arr, n);
}
