// Debug

#ifndef COPY_PHASE_STRIP
  #define IFDEBUG(x) x
  #define DLog( ... ) __NSTrace(__func__, __VA_ARGS__)
#else
  #define IFDEBUG(x)
  #define DLog( ... )
#endif

#define NSTrace( ... ) __NSTrace(__func__, __VA_ARGS__)

static void __NSTrace( const char *fnc, NSString *format, ... ) {
	va_list args;
	va_start(args, format);
	NSLogv( [[[NSString stringWithCString:fnc] stringByAppendingString:@" "] stringByAppendingString:format], args);
	va_end(args);
}
