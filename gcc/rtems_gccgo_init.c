/*
 *  Init for Go testing.
 */

#include <bsp.h>

#include <stdlib.h>

#include <rtems/rtems_bsdnet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include "networkconfig.h"

/*
 * Set up first argument
 */
static int   argc     = 1;
static char  arg0[20] = "rtems";
static char *argv[20] = { arg0 };

#if defined(MAIN_USE_REQUIRES_COMMAND_LINE)

#define COMMAND_LINE_MAXIMUM 200

#include <stdio.h>
#include <ctype.h>

void parse_arguments(
  char   *buffer,
  size_t  maximum_length
)
{
  char   *cp;
  char   *linebuf = buffer;
  size_t  length;

  for (;;) {

    #if defined(MAIN_COMMAND_LINE)
      strncpy (linebuf, MAIN_COMMAND_LINE, maximum_length);
    #else
      /*
       * Read a line
       */
      printf (">>> %s ", argv[0]);
      fflush (stdout);
      fgets (linebuf, maximum_length, stdin);

      length = strnlen( linebuf, maximum_length );
      if ( linebuf[length - 1] == '\n' || linebuf[length - 1] == '\r' ) {
	 linebuf[length - 1] = '\0';
      }
    #endif

    /*
     * Break line into arguments
     */
    cp = linebuf;
    for (;;) {
      while (isspace (*cp))
        *cp++ = '\0';
      if (*cp == '\0')
        break;
      if (argc >= ((sizeof argv / sizeof argv[0]) - 1)) {
        printf ("Too many arguments.\n");
        argc = 0;
        break;
      }
      argv[argc++] = cp;
      while (!isspace (*cp)) {
        if (*cp == '\0')
          break;
        cp++;
      }
    }
    if (argc > 1) {
      argv[argc] = NULL;
      break;
    }
    printf ("You must give some arguments!\n");
  }

  #if defined(DEBUG_COMMAND_LINE_ARGUMENTS)
    {
      int   i;
      for (i=0; i<argc ; i++ ) {
        printf( "argv[%d] = ***%s***\n", i, argv[i] );
      }
      printf( "\n" );
    }
  #endif 
}


#endif

int main( int, char ** );

void *POSIX_Init(
  void *argument
)
{
  //printk("Initializing Network\n");
  rtems_bsdnet_initialize_network ();
  //rtems_bsdnet_show_inet_routes ();
#if defined(MAIN_USE_REQUIRES_COMMAND_LINE)
  char command_line[ COMMAND_LINE_MAXIMUM ];
  parse_arguments( command_line, COMMAND_LINE_MAXIMUM );
#endif

  main(argc, argv);
  exit(0);
  return 0;
}

#if defined(__mips__)
/* GCC sometimes expects this on the mips */
void _flush_cache()
{
}
#endif

/* configuration information */

/* NOTICE: the clock driver is explicitly disabled */
#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_CONSOLE_DRIVER

#define CONFIGURE_POSIX_INIT_THREAD_TABLE
// Works with 32 Mb too, this is faster 
//#define CONFIGURE_EXECUTIVE_RAM_SIZE (5 * 1024 * 1024)
#define CONFIGURE_MAXIMUM_POSIX_MUTEXES 500
#define CONFIGURE_MAXIMUM_POSIX_SEMAPHORES 500
#define CONFIGURE_MAXIMUM_POSIX_THREADS 400
#define CONFIGURE_MAXIMUM_POSIX_CONDITION_VARIABLES  500
#define CONFIGURE_MAXIMUM_TASK_VARIABLES (2 * 400)
#define CONFIGURE_POSIX_INIT_THREAD_STACK_SIZE (32 * 1024)
#define CONFIGURE_MINIMUM_TASK_STACK_SIZE (4 * 1024)
//#define CONFIGURE_MEMORY_OVERHEAD (4 * 1024)

//#define CONFIGURE_MICROSECONDS_PER_TICK 1000
#define CONFIGURE_TICKS_PER_TIMESLICE   50
#define CONFIGURE_MICROSECONDS_PER_TICK RTEMS_MILLISECONDS_TO_MICROSECONDS(1000)

#define CONFIGURE_MAXIMUM_TASKS 20
#define CONFIGURE_MAXIMUM_SEMAPHORES 20
//#define CONFIGURE_MAXIMUM_MESSAGE_QUEUES    20

#define CONFIGURE_USE_IMFS_AS_BASE_FILESYSTEM
#define CONFIGURE_LIBIO_MAXIMUM_FILE_DESCRIPTORS 20

#define CONFIGURE_PIPES_ENABLED TRUE
#define CONFIGURE_MAXIMUM_PIPES 20
//#define CONFIGURE_MAXIMUM_BARRIERS 20

#define CONFIGURE_ZERO_WORKSPACE_AUTOMATICALLY TRUE
//#define BSP_ZERO_WORKSPACE_AUTOMATICALLY 1
#define CONFIGURE_UNIFIED_WORK_AREAS
//#define CONFIGURE_MALLOC_DIRTY
//#define CONFIGURE_ZERO_WORKSPACE_AUTOMATICALLY 1
#define CONFIGURE_STACK_CHECKER_ENABLED TRUE

#define CONFIGURE_INIT

#include <rtems/confdefs.h>

/* end of file */
