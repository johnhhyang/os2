
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
   d:	e9 bf 00 00 00       	jmp    d1 <grep+0xd1>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    p = buf;
  18:	c7 45 f0 60 10 00 00 	movl   $0x1060,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  1f:	eb 53                	jmp    74 <grep+0x74>
      *q = 0;
  21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  24:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  2e:	8b 45 08             	mov    0x8(%ebp),%eax
  31:	89 04 24             	mov    %eax,(%esp)
  34:	e8 af 01 00 00       	call   1e8 <match>
  39:	85 c0                	test   %eax,%eax
  3b:	74 2e                	je     6b <grep+0x6b>
        *q = '\n';
  3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  40:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  46:	83 c0 01             	add    $0x1,%eax
  49:	89 c2                	mov    %eax,%edx
  4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  4e:	89 d1                	mov    %edx,%ecx
  50:	29 c1                	sub    %eax,%ecx
  52:	89 c8                	mov    %ecx,%eax
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  66:	e8 69 05 00 00       	call   5d4 <write>
      }
      p = q+1;
  6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6e:	83 c0 01             	add    $0x1,%eax
  71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
    m += n;
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  74:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  7b:	00 
  7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  7f:	89 04 24             	mov    %eax,(%esp)
  82:	e8 ac 03 00 00       	call   433 <strchr>
  87:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8e:	75 91                	jne    21 <grep+0x21>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  90:	81 7d f0 60 10 00 00 	cmpl   $0x1060,-0x10(%ebp)
  97:	75 07                	jne    a0 <grep+0xa0>
      m = 0;
  99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a4:	7e 2b                	jle    d1 <grep+0xd1>
      m -= p - buf;
  a6:	ba 60 10 00 00       	mov    $0x1060,%edx
  ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ae:	89 d1                	mov    %edx,%ecx
  b0:	29 c1                	sub    %eax,%ecx
  b2:	89 c8                	mov    %ecx,%eax
  b4:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  c5:	c7 04 24 60 10 00 00 	movl   $0x1060,(%esp)
  cc:	e8 9d 04 00 00       	call   56e <memmove>
{
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
  d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d4:	ba 00 04 00 00       	mov    $0x400,%edx
  d9:	89 d1                	mov    %edx,%ecx
  db:	29 c1                	sub    %eax,%ecx
  dd:	89 c8                	mov    %ecx,%eax
  df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  e2:	81 c2 60 10 00 00    	add    $0x1060,%edx
  e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 04 24             	mov    %eax,(%esp)
  f6:	e8 d1 04 00 00       	call   5cc <read>
  fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 102:	0f 8f 0a ff ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}
 108:	c9                   	leave  
 109:	c3                   	ret    

0000010a <main>:

int
main(int argc, char *argv[])
{
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
 10d:	83 e4 f0             	and    $0xfffffff0,%esp
 110:	83 ec 20             	sub    $0x20,%esp
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 113:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 117:	7f 19                	jg     132 <main+0x28>
    printf(2, "usage: grep pattern [file ...]\n");
 119:	c7 44 24 04 38 0c 00 	movl   $0xc38,0x4(%esp)
 120:	00 
 121:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 128:	e8 3e 06 00 00       	call   76b <printf>
    exit();
 12d:	e8 82 04 00 00       	call   5b4 <exit>
  }
  pattern = argv[1];
 132:	8b 45 0c             	mov    0xc(%ebp),%eax
 135:	8b 40 04             	mov    0x4(%eax),%eax
 138:	89 44 24 18          	mov    %eax,0x18(%esp)
  
  if(argc <= 2){
 13c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 140:	7f 19                	jg     15b <main+0x51>
    grep(pattern, 0);
 142:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 149:	00 
 14a:	8b 44 24 18          	mov    0x18(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 aa fe ff ff       	call   0 <grep>
    exit();
 156:	e8 59 04 00 00       	call   5b4 <exit>
  }

  for(i = 2; i < argc; i++){
 15b:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 162:	00 
 163:	eb 75                	jmp    1da <main+0xd0>
    if((fd = open(argv[i], 0)) < 0){
 165:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 169:	c1 e0 02             	shl    $0x2,%eax
 16c:	03 45 0c             	add    0xc(%ebp),%eax
 16f:	8b 00                	mov    (%eax),%eax
 171:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 178:	00 
 179:	89 04 24             	mov    %eax,(%esp)
 17c:	e8 73 04 00 00       	call   5f4 <open>
 181:	89 44 24 14          	mov    %eax,0x14(%esp)
 185:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 18a:	79 29                	jns    1b5 <main+0xab>
      printf(1, "grep: cannot open %s\n", argv[i]);
 18c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 190:	c1 e0 02             	shl    $0x2,%eax
 193:	03 45 0c             	add    0xc(%ebp),%eax
 196:	8b 00                	mov    (%eax),%eax
 198:	89 44 24 08          	mov    %eax,0x8(%esp)
 19c:	c7 44 24 04 58 0c 00 	movl   $0xc58,0x4(%esp)
 1a3:	00 
 1a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ab:	e8 bb 05 00 00       	call   76b <printf>
      exit();
 1b0:	e8 ff 03 00 00       	call   5b4 <exit>
    }
    grep(pattern, fd);
 1b5:	8b 44 24 14          	mov    0x14(%esp),%eax
 1b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 1bd:	8b 44 24 18          	mov    0x18(%esp),%eax
 1c1:	89 04 24             	mov    %eax,(%esp)
 1c4:	e8 37 fe ff ff       	call   0 <grep>
    close(fd);
 1c9:	8b 44 24 14          	mov    0x14(%esp),%eax
 1cd:	89 04 24             	mov    %eax,(%esp)
 1d0:	e8 07 04 00 00       	call   5dc <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 1d5:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1da:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1de:	3b 45 08             	cmp    0x8(%ebp),%eax
 1e1:	7c 82                	jl     165 <main+0x5b>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 1e3:	e8 cc 03 00 00       	call   5b4 <exit>

000001e8 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1e8:	55                   	push   %ebp
 1e9:	89 e5                	mov    %esp,%ebp
 1eb:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
 1f1:	0f b6 00             	movzbl (%eax),%eax
 1f4:	3c 5e                	cmp    $0x5e,%al
 1f6:	75 17                	jne    20f <match+0x27>
    return matchhere(re+1, text);
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	8d 50 01             	lea    0x1(%eax),%edx
 1fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 201:	89 44 24 04          	mov    %eax,0x4(%esp)
 205:	89 14 24             	mov    %edx,(%esp)
 208:	e8 39 00 00 00       	call   246 <matchhere>
 20d:	eb 35                	jmp    244 <match+0x5c>
  do{  // must look at empty string
    if(matchhere(re, text))
 20f:	8b 45 0c             	mov    0xc(%ebp),%eax
 212:	89 44 24 04          	mov    %eax,0x4(%esp)
 216:	8b 45 08             	mov    0x8(%ebp),%eax
 219:	89 04 24             	mov    %eax,(%esp)
 21c:	e8 25 00 00 00       	call   246 <matchhere>
 221:	85 c0                	test   %eax,%eax
 223:	74 07                	je     22c <match+0x44>
      return 1;
 225:	b8 01 00 00 00       	mov    $0x1,%eax
 22a:	eb 18                	jmp    244 <match+0x5c>
  }while(*text++ != '\0');
 22c:	8b 45 0c             	mov    0xc(%ebp),%eax
 22f:	0f b6 00             	movzbl (%eax),%eax
 232:	84 c0                	test   %al,%al
 234:	0f 95 c0             	setne  %al
 237:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 23b:	84 c0                	test   %al,%al
 23d:	75 d0                	jne    20f <match+0x27>
  return 0;
 23f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 244:	c9                   	leave  
 245:	c3                   	ret    

00000246 <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 246:	55                   	push   %ebp
 247:	89 e5                	mov    %esp,%ebp
 249:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 24c:	8b 45 08             	mov    0x8(%ebp),%eax
 24f:	0f b6 00             	movzbl (%eax),%eax
 252:	84 c0                	test   %al,%al
 254:	75 0a                	jne    260 <matchhere+0x1a>
    return 1;
 256:	b8 01 00 00 00       	mov    $0x1,%eax
 25b:	e9 9b 00 00 00       	jmp    2fb <matchhere+0xb5>
  if(re[1] == '*')
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	83 c0 01             	add    $0x1,%eax
 266:	0f b6 00             	movzbl (%eax),%eax
 269:	3c 2a                	cmp    $0x2a,%al
 26b:	75 24                	jne    291 <matchhere+0x4b>
    return matchstar(re[0], re+2, text);
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	8d 48 02             	lea    0x2(%eax),%ecx
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	0f b6 00             	movzbl (%eax),%eax
 279:	0f be c0             	movsbl %al,%eax
 27c:	8b 55 0c             	mov    0xc(%ebp),%edx
 27f:	89 54 24 08          	mov    %edx,0x8(%esp)
 283:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 287:	89 04 24             	mov    %eax,(%esp)
 28a:	e8 6e 00 00 00       	call   2fd <matchstar>
 28f:	eb 6a                	jmp    2fb <matchhere+0xb5>
  if(re[0] == '$' && re[1] == '\0')
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	3c 24                	cmp    $0x24,%al
 299:	75 1d                	jne    2b8 <matchhere+0x72>
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	83 c0 01             	add    $0x1,%eax
 2a1:	0f b6 00             	movzbl (%eax),%eax
 2a4:	84 c0                	test   %al,%al
 2a6:	75 10                	jne    2b8 <matchhere+0x72>
    return *text == '\0';
 2a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ab:	0f b6 00             	movzbl (%eax),%eax
 2ae:	84 c0                	test   %al,%al
 2b0:	0f 94 c0             	sete   %al
 2b3:	0f b6 c0             	movzbl %al,%eax
 2b6:	eb 43                	jmp    2fb <matchhere+0xb5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bb:	0f b6 00             	movzbl (%eax),%eax
 2be:	84 c0                	test   %al,%al
 2c0:	74 34                	je     2f6 <matchhere+0xb0>
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
 2c5:	0f b6 00             	movzbl (%eax),%eax
 2c8:	3c 2e                	cmp    $0x2e,%al
 2ca:	74 10                	je     2dc <matchhere+0x96>
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 10             	movzbl (%eax),%edx
 2d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d5:	0f b6 00             	movzbl (%eax),%eax
 2d8:	38 c2                	cmp    %al,%dl
 2da:	75 1a                	jne    2f6 <matchhere+0xb0>
    return matchhere(re+1, text+1);
 2dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2df:	8d 50 01             	lea    0x1(%eax),%edx
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	83 c0 01             	add    $0x1,%eax
 2e8:	89 54 24 04          	mov    %edx,0x4(%esp)
 2ec:	89 04 24             	mov    %eax,(%esp)
 2ef:	e8 52 ff ff ff       	call   246 <matchhere>
 2f4:	eb 05                	jmp    2fb <matchhere+0xb5>
  return 0;
 2f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2fb:	c9                   	leave  
 2fc:	c3                   	ret    

000002fd <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 303:	8b 45 10             	mov    0x10(%ebp),%eax
 306:	89 44 24 04          	mov    %eax,0x4(%esp)
 30a:	8b 45 0c             	mov    0xc(%ebp),%eax
 30d:	89 04 24             	mov    %eax,(%esp)
 310:	e8 31 ff ff ff       	call   246 <matchhere>
 315:	85 c0                	test   %eax,%eax
 317:	74 07                	je     320 <matchstar+0x23>
      return 1;
 319:	b8 01 00 00 00       	mov    $0x1,%eax
 31e:	eb 2c                	jmp    34c <matchstar+0x4f>
  }while(*text!='\0' && (*text++==c || c=='.'));
 320:	8b 45 10             	mov    0x10(%ebp),%eax
 323:	0f b6 00             	movzbl (%eax),%eax
 326:	84 c0                	test   %al,%al
 328:	74 1d                	je     347 <matchstar+0x4a>
 32a:	8b 45 10             	mov    0x10(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	0f be c0             	movsbl %al,%eax
 333:	3b 45 08             	cmp    0x8(%ebp),%eax
 336:	0f 94 c0             	sete   %al
 339:	83 45 10 01          	addl   $0x1,0x10(%ebp)
 33d:	84 c0                	test   %al,%al
 33f:	75 c2                	jne    303 <matchstar+0x6>
 341:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 345:	74 bc                	je     303 <matchstar+0x6>
  return 0;
 347:	b8 00 00 00 00       	mov    $0x0,%eax
}
 34c:	c9                   	leave  
 34d:	c3                   	ret    
 34e:	90                   	nop
 34f:	90                   	nop

00000350 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	57                   	push   %edi
 354:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 355:	8b 4d 08             	mov    0x8(%ebp),%ecx
 358:	8b 55 10             	mov    0x10(%ebp),%edx
 35b:	8b 45 0c             	mov    0xc(%ebp),%eax
 35e:	89 cb                	mov    %ecx,%ebx
 360:	89 df                	mov    %ebx,%edi
 362:	89 d1                	mov    %edx,%ecx
 364:	fc                   	cld    
 365:	f3 aa                	rep stos %al,%es:(%edi)
 367:	89 ca                	mov    %ecx,%edx
 369:	89 fb                	mov    %edi,%ebx
 36b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 36e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 371:	5b                   	pop    %ebx
 372:	5f                   	pop    %edi
 373:	5d                   	pop    %ebp
 374:	c3                   	ret    

00000375 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 375:	55                   	push   %ebp
 376:	89 e5                	mov    %esp,%ebp
 378:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 381:	90                   	nop
 382:	8b 45 0c             	mov    0xc(%ebp),%eax
 385:	0f b6 10             	movzbl (%eax),%edx
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	88 10                	mov    %dl,(%eax)
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	0f b6 00             	movzbl (%eax),%eax
 393:	84 c0                	test   %al,%al
 395:	0f 95 c0             	setne  %al
 398:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 39c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3a0:	84 c0                	test   %al,%al
 3a2:	75 de                	jne    382 <strcpy+0xd>
    ;
  return os;
 3a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a7:	c9                   	leave  
 3a8:	c3                   	ret    

000003a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3a9:	55                   	push   %ebp
 3aa:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3ac:	eb 08                	jmp    3b6 <strcmp+0xd>
    p++, q++;
 3ae:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	0f b6 00             	movzbl (%eax),%eax
 3bc:	84 c0                	test   %al,%al
 3be:	74 10                	je     3d0 <strcmp+0x27>
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	0f b6 10             	movzbl (%eax),%edx
 3c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c9:	0f b6 00             	movzbl (%eax),%eax
 3cc:	38 c2                	cmp    %al,%dl
 3ce:	74 de                	je     3ae <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
 3d3:	0f b6 00             	movzbl (%eax),%eax
 3d6:	0f b6 d0             	movzbl %al,%edx
 3d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dc:	0f b6 00             	movzbl (%eax),%eax
 3df:	0f b6 c0             	movzbl %al,%eax
 3e2:	89 d1                	mov    %edx,%ecx
 3e4:	29 c1                	sub    %eax,%ecx
 3e6:	89 c8                	mov    %ecx,%eax
}
 3e8:	5d                   	pop    %ebp
 3e9:	c3                   	ret    

000003ea <strlen>:

uint
strlen(char *s)
{
 3ea:	55                   	push   %ebp
 3eb:	89 e5                	mov    %esp,%ebp
 3ed:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3f7:	eb 04                	jmp    3fd <strlen+0x13>
 3f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 400:	03 45 08             	add    0x8(%ebp),%eax
 403:	0f b6 00             	movzbl (%eax),%eax
 406:	84 c0                	test   %al,%al
 408:	75 ef                	jne    3f9 <strlen+0xf>
    ;
  return n;
 40a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 40d:	c9                   	leave  
 40e:	c3                   	ret    

0000040f <memset>:

void*
memset(void *dst, int c, uint n)
{
 40f:	55                   	push   %ebp
 410:	89 e5                	mov    %esp,%ebp
 412:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 415:	8b 45 10             	mov    0x10(%ebp),%eax
 418:	89 44 24 08          	mov    %eax,0x8(%esp)
 41c:	8b 45 0c             	mov    0xc(%ebp),%eax
 41f:	89 44 24 04          	mov    %eax,0x4(%esp)
 423:	8b 45 08             	mov    0x8(%ebp),%eax
 426:	89 04 24             	mov    %eax,(%esp)
 429:	e8 22 ff ff ff       	call   350 <stosb>
  return dst;
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 431:	c9                   	leave  
 432:	c3                   	ret    

00000433 <strchr>:

char*
strchr(const char *s, char c)
{
 433:	55                   	push   %ebp
 434:	89 e5                	mov    %esp,%ebp
 436:	83 ec 04             	sub    $0x4,%esp
 439:	8b 45 0c             	mov    0xc(%ebp),%eax
 43c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 43f:	eb 14                	jmp    455 <strchr+0x22>
    if(*s == c)
 441:	8b 45 08             	mov    0x8(%ebp),%eax
 444:	0f b6 00             	movzbl (%eax),%eax
 447:	3a 45 fc             	cmp    -0x4(%ebp),%al
 44a:	75 05                	jne    451 <strchr+0x1e>
      return (char*)s;
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	eb 13                	jmp    464 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 451:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 455:	8b 45 08             	mov    0x8(%ebp),%eax
 458:	0f b6 00             	movzbl (%eax),%eax
 45b:	84 c0                	test   %al,%al
 45d:	75 e2                	jne    441 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 45f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 464:	c9                   	leave  
 465:	c3                   	ret    

00000466 <gets>:

char*
gets(char *buf, int max)
{
 466:	55                   	push   %ebp
 467:	89 e5                	mov    %esp,%ebp
 469:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 46c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 473:	eb 44                	jmp    4b9 <gets+0x53>
    cc = read(0, &c, 1);
 475:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 47c:	00 
 47d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 480:	89 44 24 04          	mov    %eax,0x4(%esp)
 484:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 48b:	e8 3c 01 00 00       	call   5cc <read>
 490:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 493:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 497:	7e 2d                	jle    4c6 <gets+0x60>
      break;
    buf[i++] = c;
 499:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49c:	03 45 08             	add    0x8(%ebp),%eax
 49f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 4a3:	88 10                	mov    %dl,(%eax)
 4a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ad:	3c 0a                	cmp    $0xa,%al
 4af:	74 16                	je     4c7 <gets+0x61>
 4b1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b5:	3c 0d                	cmp    $0xd,%al
 4b7:	74 0e                	je     4c7 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bc:	83 c0 01             	add    $0x1,%eax
 4bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4c2:	7c b1                	jl     475 <gets+0xf>
 4c4:	eb 01                	jmp    4c7 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4c6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ca:	03 45 08             	add    0x8(%ebp),%eax
 4cd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d3:	c9                   	leave  
 4d4:	c3                   	ret    

000004d5 <stat>:

int
stat(char *n, struct stat *st)
{
 4d5:	55                   	push   %ebp
 4d6:	89 e5                	mov    %esp,%ebp
 4d8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4e2:	00 
 4e3:	8b 45 08             	mov    0x8(%ebp),%eax
 4e6:	89 04 24             	mov    %eax,(%esp)
 4e9:	e8 06 01 00 00       	call   5f4 <open>
 4ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f5:	79 07                	jns    4fe <stat+0x29>
    return -1;
 4f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4fc:	eb 23                	jmp    521 <stat+0x4c>
  r = fstat(fd, st);
 4fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 501:	89 44 24 04          	mov    %eax,0x4(%esp)
 505:	8b 45 f4             	mov    -0xc(%ebp),%eax
 508:	89 04 24             	mov    %eax,(%esp)
 50b:	e8 fc 00 00 00       	call   60c <fstat>
 510:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 513:	8b 45 f4             	mov    -0xc(%ebp),%eax
 516:	89 04 24             	mov    %eax,(%esp)
 519:	e8 be 00 00 00       	call   5dc <close>
  return r;
 51e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 521:	c9                   	leave  
 522:	c3                   	ret    

00000523 <atoi>:

int
atoi(const char *s)
{
 523:	55                   	push   %ebp
 524:	89 e5                	mov    %esp,%ebp
 526:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 529:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 530:	eb 23                	jmp    555 <atoi+0x32>
    n = n*10 + *s++ - '0';
 532:	8b 55 fc             	mov    -0x4(%ebp),%edx
 535:	89 d0                	mov    %edx,%eax
 537:	c1 e0 02             	shl    $0x2,%eax
 53a:	01 d0                	add    %edx,%eax
 53c:	01 c0                	add    %eax,%eax
 53e:	89 c2                	mov    %eax,%edx
 540:	8b 45 08             	mov    0x8(%ebp),%eax
 543:	0f b6 00             	movzbl (%eax),%eax
 546:	0f be c0             	movsbl %al,%eax
 549:	01 d0                	add    %edx,%eax
 54b:	83 e8 30             	sub    $0x30,%eax
 54e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 551:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 555:	8b 45 08             	mov    0x8(%ebp),%eax
 558:	0f b6 00             	movzbl (%eax),%eax
 55b:	3c 2f                	cmp    $0x2f,%al
 55d:	7e 0a                	jle    569 <atoi+0x46>
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	3c 39                	cmp    $0x39,%al
 567:	7e c9                	jle    532 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 569:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 56c:	c9                   	leave  
 56d:	c3                   	ret    

0000056e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 56e:	55                   	push   %ebp
 56f:	89 e5                	mov    %esp,%ebp
 571:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 574:	8b 45 08             	mov    0x8(%ebp),%eax
 577:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 57a:	8b 45 0c             	mov    0xc(%ebp),%eax
 57d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 580:	eb 13                	jmp    595 <memmove+0x27>
    *dst++ = *src++;
 582:	8b 45 f8             	mov    -0x8(%ebp),%eax
 585:	0f b6 10             	movzbl (%eax),%edx
 588:	8b 45 fc             	mov    -0x4(%ebp),%eax
 58b:	88 10                	mov    %dl,(%eax)
 58d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 591:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 595:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 599:	0f 9f c0             	setg   %al
 59c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5a0:	84 c0                	test   %al,%al
 5a2:	75 de                	jne    582 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5a7:	c9                   	leave  
 5a8:	c3                   	ret    
 5a9:	90                   	nop
 5aa:	90                   	nop
 5ab:	90                   	nop

000005ac <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5ac:	b8 01 00 00 00       	mov    $0x1,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <exit>:
SYSCALL(exit)
 5b4:	b8 02 00 00 00       	mov    $0x2,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <wait>:
SYSCALL(wait)
 5bc:	b8 03 00 00 00       	mov    $0x3,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <pipe>:
SYSCALL(pipe)
 5c4:	b8 04 00 00 00       	mov    $0x4,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <read>:
SYSCALL(read)
 5cc:	b8 05 00 00 00       	mov    $0x5,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <write>:
SYSCALL(write)
 5d4:	b8 10 00 00 00       	mov    $0x10,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <close>:
SYSCALL(close)
 5dc:	b8 15 00 00 00       	mov    $0x15,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <kill>:
SYSCALL(kill)
 5e4:	b8 06 00 00 00       	mov    $0x6,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <exec>:
SYSCALL(exec)
 5ec:	b8 07 00 00 00       	mov    $0x7,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <open>:
SYSCALL(open)
 5f4:	b8 0f 00 00 00       	mov    $0xf,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <mknod>:
SYSCALL(mknod)
 5fc:	b8 11 00 00 00       	mov    $0x11,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <unlink>:
SYSCALL(unlink)
 604:	b8 12 00 00 00       	mov    $0x12,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <fstat>:
SYSCALL(fstat)
 60c:	b8 08 00 00 00       	mov    $0x8,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <link>:
SYSCALL(link)
 614:	b8 13 00 00 00       	mov    $0x13,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <mkdir>:
SYSCALL(mkdir)
 61c:	b8 14 00 00 00       	mov    $0x14,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <chdir>:
SYSCALL(chdir)
 624:	b8 09 00 00 00       	mov    $0x9,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <dup>:
SYSCALL(dup)
 62c:	b8 0a 00 00 00       	mov    $0xa,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <getpid>:
SYSCALL(getpid)
 634:	b8 0b 00 00 00       	mov    $0xb,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <sbrk>:
SYSCALL(sbrk)
 63c:	b8 0c 00 00 00       	mov    $0xc,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <sleep>:
SYSCALL(sleep)
 644:	b8 0d 00 00 00       	mov    $0xd,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <uptime>:
SYSCALL(uptime)
 64c:	b8 0e 00 00 00       	mov    $0xe,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <halt>:
SYSCALL(halt)
 654:	b8 16 00 00 00       	mov    $0x16,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <clone>:

SYSCALL(clone)
 65c:	b8 19 00 00 00       	mov    $0x19,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <join>:
SYSCALL(join)
 664:	b8 1a 00 00 00       	mov    $0x1a,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <texit>:
SYSCALL(texit)
 66c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <mutex_init>:
SYSCALL(mutex_init)
 674:	b8 1c 00 00 00       	mov    $0x1c,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <mutex_destroy>:
SYSCALL(mutex_destroy)
 67c:	b8 1d 00 00 00       	mov    $0x1d,%eax
 681:	cd 40                	int    $0x40
 683:	c3                   	ret    

00000684 <mutex_lock>:
SYSCALL(mutex_lock)
 684:	b8 1e 00 00 00       	mov    $0x1e,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <mutex_unlock>:
 68c:	b8 1f 00 00 00       	mov    $0x1f,%eax
 691:	cd 40                	int    $0x40
 693:	c3                   	ret    

00000694 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 694:	55                   	push   %ebp
 695:	89 e5                	mov    %esp,%ebp
 697:	83 ec 28             	sub    $0x28,%esp
 69a:	8b 45 0c             	mov    0xc(%ebp),%eax
 69d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6a0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6a7:	00 
 6a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 6af:	8b 45 08             	mov    0x8(%ebp),%eax
 6b2:	89 04 24             	mov    %eax,(%esp)
 6b5:	e8 1a ff ff ff       	call   5d4 <write>
}
 6ba:	c9                   	leave  
 6bb:	c3                   	ret    

000006bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6bc:	55                   	push   %ebp
 6bd:	89 e5                	mov    %esp,%ebp
 6bf:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6c9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6cd:	74 17                	je     6e6 <printint+0x2a>
 6cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6d3:	79 11                	jns    6e6 <printint+0x2a>
    neg = 1;
 6d5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6df:	f7 d8                	neg    %eax
 6e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6e4:	eb 06                	jmp    6ec <printint+0x30>
  } else {
    x = xx;
 6e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f9:	ba 00 00 00 00       	mov    $0x0,%edx
 6fe:	f7 f1                	div    %ecx
 700:	89 d0                	mov    %edx,%eax
 702:	0f b6 90 14 10 00 00 	movzbl 0x1014(%eax),%edx
 709:	8d 45 dc             	lea    -0x24(%ebp),%eax
 70c:	03 45 f4             	add    -0xc(%ebp),%eax
 70f:	88 10                	mov    %dl,(%eax)
 711:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 715:	8b 55 10             	mov    0x10(%ebp),%edx
 718:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 71b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 71e:	ba 00 00 00 00       	mov    $0x0,%edx
 723:	f7 75 d4             	divl   -0x2c(%ebp)
 726:	89 45 ec             	mov    %eax,-0x14(%ebp)
 729:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 72d:	75 c4                	jne    6f3 <printint+0x37>
  if(neg)
 72f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 733:	74 2a                	je     75f <printint+0xa3>
    buf[i++] = '-';
 735:	8d 45 dc             	lea    -0x24(%ebp),%eax
 738:	03 45 f4             	add    -0xc(%ebp),%eax
 73b:	c6 00 2d             	movb   $0x2d,(%eax)
 73e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 742:	eb 1b                	jmp    75f <printint+0xa3>
    putc(fd, buf[i]);
 744:	8d 45 dc             	lea    -0x24(%ebp),%eax
 747:	03 45 f4             	add    -0xc(%ebp),%eax
 74a:	0f b6 00             	movzbl (%eax),%eax
 74d:	0f be c0             	movsbl %al,%eax
 750:	89 44 24 04          	mov    %eax,0x4(%esp)
 754:	8b 45 08             	mov    0x8(%ebp),%eax
 757:	89 04 24             	mov    %eax,(%esp)
 75a:	e8 35 ff ff ff       	call   694 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 75f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 763:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 767:	79 db                	jns    744 <printint+0x88>
    putc(fd, buf[i]);
}
 769:	c9                   	leave  
 76a:	c3                   	ret    

0000076b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 76b:	55                   	push   %ebp
 76c:	89 e5                	mov    %esp,%ebp
 76e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 771:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 778:	8d 45 0c             	lea    0xc(%ebp),%eax
 77b:	83 c0 04             	add    $0x4,%eax
 77e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 781:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 788:	e9 7d 01 00 00       	jmp    90a <printf+0x19f>
    c = fmt[i] & 0xff;
 78d:	8b 55 0c             	mov    0xc(%ebp),%edx
 790:	8b 45 f0             	mov    -0x10(%ebp),%eax
 793:	01 d0                	add    %edx,%eax
 795:	0f b6 00             	movzbl (%eax),%eax
 798:	0f be c0             	movsbl %al,%eax
 79b:	25 ff 00 00 00       	and    $0xff,%eax
 7a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7a7:	75 2c                	jne    7d5 <printf+0x6a>
      if(c == '%'){
 7a9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ad:	75 0c                	jne    7bb <printf+0x50>
        state = '%';
 7af:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7b6:	e9 4b 01 00 00       	jmp    906 <printf+0x19b>
      } else {
        putc(fd, c);
 7bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7be:	0f be c0             	movsbl %al,%eax
 7c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c5:	8b 45 08             	mov    0x8(%ebp),%eax
 7c8:	89 04 24             	mov    %eax,(%esp)
 7cb:	e8 c4 fe ff ff       	call   694 <putc>
 7d0:	e9 31 01 00 00       	jmp    906 <printf+0x19b>
      }
    } else if(state == '%'){
 7d5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7d9:	0f 85 27 01 00 00    	jne    906 <printf+0x19b>
      if(c == 'd'){
 7df:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7e3:	75 2d                	jne    812 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e8:	8b 00                	mov    (%eax),%eax
 7ea:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7f1:	00 
 7f2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7f9:	00 
 7fa:	89 44 24 04          	mov    %eax,0x4(%esp)
 7fe:	8b 45 08             	mov    0x8(%ebp),%eax
 801:	89 04 24             	mov    %eax,(%esp)
 804:	e8 b3 fe ff ff       	call   6bc <printint>
        ap++;
 809:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 80d:	e9 ed 00 00 00       	jmp    8ff <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 812:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 816:	74 06                	je     81e <printf+0xb3>
 818:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 81c:	75 2d                	jne    84b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 81e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 821:	8b 00                	mov    (%eax),%eax
 823:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 82a:	00 
 82b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 832:	00 
 833:	89 44 24 04          	mov    %eax,0x4(%esp)
 837:	8b 45 08             	mov    0x8(%ebp),%eax
 83a:	89 04 24             	mov    %eax,(%esp)
 83d:	e8 7a fe ff ff       	call   6bc <printint>
        ap++;
 842:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 846:	e9 b4 00 00 00       	jmp    8ff <printf+0x194>
      } else if(c == 's'){
 84b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 84f:	75 46                	jne    897 <printf+0x12c>
        s = (char*)*ap;
 851:	8b 45 e8             	mov    -0x18(%ebp),%eax
 854:	8b 00                	mov    (%eax),%eax
 856:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 859:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 85d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 861:	75 27                	jne    88a <printf+0x11f>
          s = "(null)";
 863:	c7 45 f4 6e 0c 00 00 	movl   $0xc6e,-0xc(%ebp)
        while(*s != 0){
 86a:	eb 1e                	jmp    88a <printf+0x11f>
          putc(fd, *s);
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	0f b6 00             	movzbl (%eax),%eax
 872:	0f be c0             	movsbl %al,%eax
 875:	89 44 24 04          	mov    %eax,0x4(%esp)
 879:	8b 45 08             	mov    0x8(%ebp),%eax
 87c:	89 04 24             	mov    %eax,(%esp)
 87f:	e8 10 fe ff ff       	call   694 <putc>
          s++;
 884:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 888:	eb 01                	jmp    88b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 88a:	90                   	nop
 88b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88e:	0f b6 00             	movzbl (%eax),%eax
 891:	84 c0                	test   %al,%al
 893:	75 d7                	jne    86c <printf+0x101>
 895:	eb 68                	jmp    8ff <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 897:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 89b:	75 1d                	jne    8ba <printf+0x14f>
        putc(fd, *ap);
 89d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a0:	8b 00                	mov    (%eax),%eax
 8a2:	0f be c0             	movsbl %al,%eax
 8a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 8a9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ac:	89 04 24             	mov    %eax,(%esp)
 8af:	e8 e0 fd ff ff       	call   694 <putc>
        ap++;
 8b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8b8:	eb 45                	jmp    8ff <printf+0x194>
      } else if(c == '%'){
 8ba:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8be:	75 17                	jne    8d7 <printf+0x16c>
        putc(fd, c);
 8c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c3:	0f be c0             	movsbl %al,%eax
 8c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 8ca:	8b 45 08             	mov    0x8(%ebp),%eax
 8cd:	89 04 24             	mov    %eax,(%esp)
 8d0:	e8 bf fd ff ff       	call   694 <putc>
 8d5:	eb 28                	jmp    8ff <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8d7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8de:	00 
 8df:	8b 45 08             	mov    0x8(%ebp),%eax
 8e2:	89 04 24             	mov    %eax,(%esp)
 8e5:	e8 aa fd ff ff       	call   694 <putc>
        putc(fd, c);
 8ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ed:	0f be c0             	movsbl %al,%eax
 8f0:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f4:	8b 45 08             	mov    0x8(%ebp),%eax
 8f7:	89 04 24             	mov    %eax,(%esp)
 8fa:	e8 95 fd ff ff       	call   694 <putc>
      }
      state = 0;
 8ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 906:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 90a:	8b 55 0c             	mov    0xc(%ebp),%edx
 90d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 910:	01 d0                	add    %edx,%eax
 912:	0f b6 00             	movzbl (%eax),%eax
 915:	84 c0                	test   %al,%al
 917:	0f 85 70 fe ff ff    	jne    78d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 91d:	c9                   	leave  
 91e:	c3                   	ret    
 91f:	90                   	nop

00000920 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 920:	55                   	push   %ebp
 921:	89 e5                	mov    %esp,%ebp
 923:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 926:	8b 45 08             	mov    0x8(%ebp),%eax
 929:	83 e8 08             	sub    $0x8,%eax
 92c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92f:	a1 48 10 00 00       	mov    0x1048,%eax
 934:	89 45 fc             	mov    %eax,-0x4(%ebp)
 937:	eb 24                	jmp    95d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 941:	77 12                	ja     955 <free+0x35>
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 949:	77 24                	ja     96f <free+0x4f>
 94b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94e:	8b 00                	mov    (%eax),%eax
 950:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 953:	77 1a                	ja     96f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 955:	8b 45 fc             	mov    -0x4(%ebp),%eax
 958:	8b 00                	mov    (%eax),%eax
 95a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 95d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 960:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 963:	76 d4                	jbe    939 <free+0x19>
 965:	8b 45 fc             	mov    -0x4(%ebp),%eax
 968:	8b 00                	mov    (%eax),%eax
 96a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 96d:	76 ca                	jbe    939 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 96f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 972:	8b 40 04             	mov    0x4(%eax),%eax
 975:	c1 e0 03             	shl    $0x3,%eax
 978:	89 c2                	mov    %eax,%edx
 97a:	03 55 f8             	add    -0x8(%ebp),%edx
 97d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 980:	8b 00                	mov    (%eax),%eax
 982:	39 c2                	cmp    %eax,%edx
 984:	75 24                	jne    9aa <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 986:	8b 45 f8             	mov    -0x8(%ebp),%eax
 989:	8b 50 04             	mov    0x4(%eax),%edx
 98c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98f:	8b 00                	mov    (%eax),%eax
 991:	8b 40 04             	mov    0x4(%eax),%eax
 994:	01 c2                	add    %eax,%edx
 996:	8b 45 f8             	mov    -0x8(%ebp),%eax
 999:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 99c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99f:	8b 00                	mov    (%eax),%eax
 9a1:	8b 10                	mov    (%eax),%edx
 9a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a6:	89 10                	mov    %edx,(%eax)
 9a8:	eb 0a                	jmp    9b4 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 9aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ad:	8b 10                	mov    (%eax),%edx
 9af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b7:	8b 40 04             	mov    0x4(%eax),%eax
 9ba:	c1 e0 03             	shl    $0x3,%eax
 9bd:	03 45 fc             	add    -0x4(%ebp),%eax
 9c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9c3:	75 20                	jne    9e5 <free+0xc5>
    p->s.size += bp->s.size;
 9c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c8:	8b 50 04             	mov    0x4(%eax),%edx
 9cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ce:	8b 40 04             	mov    0x4(%eax),%eax
 9d1:	01 c2                	add    %eax,%edx
 9d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9dc:	8b 10                	mov    (%eax),%edx
 9de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e1:	89 10                	mov    %edx,(%eax)
 9e3:	eb 08                	jmp    9ed <free+0xcd>
  } else
    p->s.ptr = bp;
 9e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9eb:	89 10                	mov    %edx,(%eax)
  freep = p;
 9ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f0:	a3 48 10 00 00       	mov    %eax,0x1048
}
 9f5:	c9                   	leave  
 9f6:	c3                   	ret    

000009f7 <morecore>:

static Header*
morecore(uint nu)
{
 9f7:	55                   	push   %ebp
 9f8:	89 e5                	mov    %esp,%ebp
 9fa:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9fd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a04:	77 07                	ja     a0d <morecore+0x16>
    nu = 4096;
 a06:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a0d:	8b 45 08             	mov    0x8(%ebp),%eax
 a10:	c1 e0 03             	shl    $0x3,%eax
 a13:	89 04 24             	mov    %eax,(%esp)
 a16:	e8 21 fc ff ff       	call   63c <sbrk>
 a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a1e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a22:	75 07                	jne    a2b <morecore+0x34>
    return 0;
 a24:	b8 00 00 00 00       	mov    $0x0,%eax
 a29:	eb 22                	jmp    a4d <morecore+0x56>
  hp = (Header*)p;
 a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a34:	8b 55 08             	mov    0x8(%ebp),%edx
 a37:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3d:	83 c0 08             	add    $0x8,%eax
 a40:	89 04 24             	mov    %eax,(%esp)
 a43:	e8 d8 fe ff ff       	call   920 <free>
  return freep;
 a48:	a1 48 10 00 00       	mov    0x1048,%eax
}
 a4d:	c9                   	leave  
 a4e:	c3                   	ret    

00000a4f <malloc>:

void*
malloc(uint nbytes)
{
 a4f:	55                   	push   %ebp
 a50:	89 e5                	mov    %esp,%ebp
 a52:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a55:	8b 45 08             	mov    0x8(%ebp),%eax
 a58:	83 c0 07             	add    $0x7,%eax
 a5b:	c1 e8 03             	shr    $0x3,%eax
 a5e:	83 c0 01             	add    $0x1,%eax
 a61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a64:	a1 48 10 00 00       	mov    0x1048,%eax
 a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a70:	75 23                	jne    a95 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a72:	c7 45 f0 40 10 00 00 	movl   $0x1040,-0x10(%ebp)
 a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7c:	a3 48 10 00 00       	mov    %eax,0x1048
 a81:	a1 48 10 00 00       	mov    0x1048,%eax
 a86:	a3 40 10 00 00       	mov    %eax,0x1040
    base.s.size = 0;
 a8b:	c7 05 44 10 00 00 00 	movl   $0x0,0x1044
 a92:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a98:	8b 00                	mov    (%eax),%eax
 a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa0:	8b 40 04             	mov    0x4(%eax),%eax
 aa3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aa6:	72 4d                	jb     af5 <malloc+0xa6>
      if(p->s.size == nunits)
 aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aab:	8b 40 04             	mov    0x4(%eax),%eax
 aae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ab1:	75 0c                	jne    abf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab6:	8b 10                	mov    (%eax),%edx
 ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abb:	89 10                	mov    %edx,(%eax)
 abd:	eb 26                	jmp    ae5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac2:	8b 40 04             	mov    0x4(%eax),%eax
 ac5:	89 c2                	mov    %eax,%edx
 ac7:	2b 55 ec             	sub    -0x14(%ebp),%edx
 aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad3:	8b 40 04             	mov    0x4(%eax),%eax
 ad6:	c1 e0 03             	shl    $0x3,%eax
 ad9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adf:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ae2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae8:	a3 48 10 00 00       	mov    %eax,0x1048
      return (void*)(p + 1);
 aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af0:	83 c0 08             	add    $0x8,%eax
 af3:	eb 38                	jmp    b2d <malloc+0xde>
    }
    if(p == freep)
 af5:	a1 48 10 00 00       	mov    0x1048,%eax
 afa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 afd:	75 1b                	jne    b1a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b02:	89 04 24             	mov    %eax,(%esp)
 b05:	e8 ed fe ff ff       	call   9f7 <morecore>
 b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b11:	75 07                	jne    b1a <malloc+0xcb>
        return 0;
 b13:	b8 00 00 00 00       	mov    $0x0,%eax
 b18:	eb 13                	jmp    b2d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b23:	8b 00                	mov    (%eax),%eax
 b25:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b28:	e9 70 ff ff ff       	jmp    a9d <malloc+0x4e>
}
 b2d:	c9                   	leave  
 b2e:	c3                   	ret    
 b2f:	90                   	nop

00000b30 <pthread_create>:
	clone's 3rd argument, *stek, should be allocated here?
*/

#define PAGESIZE (4096)  //Maybe 4092??

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void*), void *arg){
 b30:	55                   	push   %ebp
 b31:	89 e5                	mov    %esp,%ebp
 b33:	83 ec 28             	sub    $0x28,%esp

	void *mystek = malloc((uint)PAGESIZE*2); //Why do we need the *2?
 b36:	c7 04 24 00 20 00 00 	movl   $0x2000,(%esp)
 b3d:	e8 0d ff ff ff       	call   a4f <malloc>
 b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
//zzddhhtjzz/xv6/blob/master
	if((uint)mystek % PAGESIZE){
 b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b48:	25 ff 0f 00 00       	and    $0xfff,%eax
 b4d:	85 c0                	test   %eax,%eax
 b4f:	74 15                	je     b66 <pthread_create+0x36>
		mystek += 4096 - ((uint)mystek % PAGESIZE);
 b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b54:	89 c2                	mov    %eax,%edx
 b56:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 b5c:	b8 00 10 00 00       	mov    $0x1000,%eax
 b61:	29 d0                	sub    %edx,%eax
 b63:	01 45 f4             	add    %eax,-0xc(%ebp)
	}
	thread->pid = clone(start_routine, arg, mystek);
 b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b69:	89 44 24 08          	mov    %eax,0x8(%esp)
 b6d:	8b 45 14             	mov    0x14(%ebp),%eax
 b70:	89 44 24 04          	mov    %eax,0x4(%esp)
 b74:	8b 45 10             	mov    0x10(%ebp),%eax
 b77:	89 04 24             	mov    %eax,(%esp)
 b7a:	e8 dd fa ff ff       	call   65c <clone>
 b7f:	8b 55 08             	mov    0x8(%ebp),%edx
 b82:	89 02                	mov    %eax,(%edx)
	return thread->pid;
 b84:	8b 45 08             	mov    0x8(%ebp),%eax
 b87:	8b 00                	mov    (%eax),%eax
}
 b89:	c9                   	leave  
 b8a:	c3                   	ret    

00000b8b <pthread_join>:

int pthread_join(pthread_t thread, void **retval){
 b8b:	55                   	push   %ebp
 b8c:	89 e5                	mov    %esp,%ebp
 b8e:	83 ec 28             	sub    $0x28,%esp

	void *stek;

	join((int)thread.pid, &stek, (void*)retval);
 b91:	8b 45 08             	mov    0x8(%ebp),%eax
 b94:	8b 55 0c             	mov    0xc(%ebp),%edx
 b97:	89 54 24 08          	mov    %edx,0x8(%esp)
 b9b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 b9e:	89 54 24 04          	mov    %edx,0x4(%esp)
 ba2:	89 04 24             	mov    %eax,(%esp)
 ba5:	e8 ba fa ff ff       	call   664 <join>

	free(stek);
 baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bad:	89 04 24             	mov    %eax,(%esp)
 bb0:	e8 6b fd ff ff       	call   920 <free>

	return 0;
 bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 bba:	c9                   	leave  
 bbb:	c3                   	ret    

00000bbc <pthread_exit>:

int pthread_exit(void *retval){
 bbc:	55                   	push   %ebp
 bbd:	89 e5                	mov    %esp,%ebp
 bbf:	83 ec 18             	sub    $0x18,%esp

	texit(retval);
 bc2:	8b 45 08             	mov    0x8(%ebp),%eax
 bc5:	89 04 24             	mov    %eax,(%esp)
 bc8:	e8 9f fa ff ff       	call   66c <texit>

	return 0;
 bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 bd2:	c9                   	leave  
 bd3:	c3                   	ret    

00000bd4 <pthread_mutex_init>:


int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr_t *attr){
 bd4:	55                   	push   %ebp
 bd5:	89 e5                	mov    %esp,%ebp
 bd7:	83 ec 18             	sub    $0x18,%esp

	int mid = mutex_init();
 bda:	e8 95 fa ff ff       	call   674 <mutex_init>
 bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//returns the id of the initalized mutex
	return mid;
 be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 be5:	c9                   	leave  
 be6:	c3                   	ret    

00000be7 <pthread_mutex_destroy>:


int pthread_mutex_destroy(pthread_mutex_t *mutex){
 be7:	55                   	push   %ebp
 be8:	89 e5                	mov    %esp,%ebp
 bea:	83 ec 18             	sub    $0x18,%esp

	mutex_destroy(mutex->mid);
 bed:	8b 45 08             	mov    0x8(%ebp),%eax
 bf0:	8b 40 04             	mov    0x4(%eax),%eax
 bf3:	89 04 24             	mov    %eax,(%esp)
 bf6:	e8 81 fa ff ff       	call   67c <mutex_destroy>
	return 0;
 bfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 c00:	c9                   	leave  
 c01:	c3                   	ret    

00000c02 <pthread_mutex_lock>:


int pthread_mutex_lock(pthread_mutex_t *mutex){
 c02:	55                   	push   %ebp
 c03:	89 e5                	mov    %esp,%ebp
 c05:	83 ec 18             	sub    $0x18,%esp

	mutex_lock(mutex->mid);
 c08:	8b 45 08             	mov    0x8(%ebp),%eax
 c0b:	8b 40 04             	mov    0x4(%eax),%eax
 c0e:	89 04 24             	mov    %eax,(%esp)
 c11:	e8 6e fa ff ff       	call   684 <mutex_lock>
	return 0;
 c16:	b8 00 00 00 00       	mov    $0x0,%eax
}
 c1b:	c9                   	leave  
 c1c:	c3                   	ret    

00000c1d <pthread_mutex_unlock>:


int pthread_mutex_unlock(pthread_mutex_t *mutex){
 c1d:	55                   	push   %ebp
 c1e:	89 e5                	mov    %esp,%ebp
 c20:	83 ec 18             	sub    $0x18,%esp

	mutex_unlock(mutex->mid);
 c23:	8b 45 08             	mov    0x8(%ebp),%eax
 c26:	8b 40 04             	mov    0x4(%eax),%eax
 c29:	89 04 24             	mov    %eax,(%esp)
 c2c:	e8 5b fa ff ff       	call   68c <mutex_unlock>
	return 0;
 c31:	b8 00 00 00 00       	mov    $0x0,%eax
 c36:	c9                   	leave  
 c37:	c3                   	ret    
