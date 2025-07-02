#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <syslog.h> 
int main (int argc , char *argv[])
{

char * writerFile , *writerStr;
openlog(NULL,0,LOG_USER);

if(argc != 3)
{
syslog(LOG_ERR,"invalid number of arguments\n");
closelog();
return 1;
}

writerFile = argv[1];
writerStr = argv [2];

FILE *file = fopen(writerFile ,"w");
if(file == NULL)
{
//fprintf(stderr , "Value of errno attempting to open file %s: %d\n",writerFile , errno);
//perror("perror returned");
syslog(LOG_ERR, "Could not open file\n");

//return 1;
}
else
{
fprintf(file,writerStr);
syslog(LOG_DEBUG , "Writing %s to %s \n " , writerStr , writerFile);
fclose(file);
}

return 0;
}
