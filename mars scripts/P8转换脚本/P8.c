#include<stdio.h>
#include<string.h>
#include<stdlib.h>

int main(){
	FILE* fp, *fpnew;
	char s[100];
	fp = fopen("¼ÆËãÆ÷.txt", "r+");
	fpnew = fopen("¼ÆËãÆ÷1.txt", "w");
	fprintf(fpnew, "memory_initialization_radix=16;\n");
	fprintf(fpnew, "memory_initialization_vector=\n");
	while (fgets(s, 50, fp) != EOF){
		s[8] = ',';
		s[9] = '\n';
		fputs(s, fpnew);
	}
	fclose(fp);
	fclose(fpnew);
	return 0;
}