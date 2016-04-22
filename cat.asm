
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   6:	eb 1b                	jmp    23 <cat+0x23>
    write(1, buf, n);
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 a0 0d 00 	movl   $0xda0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 71 03 00 00       	call   394 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2a:	00 
  2b:	c7 44 24 04 a0 0d 00 	movl   $0xda0,0x4(%esp)
  32:	00 
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 4e 03 00 00       	call   38c <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 f8 09 00 	movl   $0x9f8,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 ca 04 00 00       	call   52b <printf>
    exit();
  61:	e8 0e 03 00 00       	call   374 <exit>
  }
}
  66:	c9                   	leave  
  67:	c3                   	ret    

00000068 <main>:

int
main(int argc, char *argv[])
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	83 e4 f0             	and    $0xfffffff0,%esp
  6e:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  71:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  75:	7f 11                	jg     88 <main+0x20>
    cat(0);
  77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  7e:	e8 7d ff ff ff       	call   0 <cat>
    exit();
  83:	e8 ec 02 00 00       	call   374 <exit>
  }

  for(i = 1; i < argc; i++){
  88:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  8f:	00 
  90:	eb 6d                	jmp    ff <main+0x97>
    if((fd = open(argv[i], 0)) < 0){
  92:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  96:	c1 e0 02             	shl    $0x2,%eax
  99:	03 45 0c             	add    0xc(%ebp),%eax
  9c:	8b 00                	mov    (%eax),%eax
  9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  a5:	00 
  a6:	89 04 24             	mov    %eax,(%esp)
  a9:	e8 06 03 00 00       	call   3b4 <open>
  ae:	89 44 24 18          	mov    %eax,0x18(%esp)
  b2:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  b7:	79 29                	jns    e2 <main+0x7a>
      printf(1, "cat: cannot open %s\n", argv[i]);
  b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  bd:	c1 e0 02             	shl    $0x2,%eax
  c0:	03 45 0c             	add    0xc(%ebp),%eax
  c3:	8b 00                	mov    (%eax),%eax
  c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  c9:	c7 44 24 04 09 0a 00 	movl   $0xa09,0x4(%esp)
  d0:	00 
  d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d8:	e8 4e 04 00 00       	call   52b <printf>
      exit();
  dd:	e8 92 02 00 00       	call   374 <exit>
    }
    cat(fd);
  e2:	8b 44 24 18          	mov    0x18(%esp),%eax
  e6:	89 04 24             	mov    %eax,(%esp)
  e9:	e8 12 ff ff ff       	call   0 <cat>
    close(fd);
  ee:	8b 44 24 18          	mov    0x18(%esp),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 a2 02 00 00       	call   39c <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  fa:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  ff:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 103:	3b 45 08             	cmp    0x8(%ebp),%eax
 106:	7c 8a                	jl     92 <main+0x2a>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 108:	e8 67 02 00 00       	call   374 <exit>
 10d:	90                   	nop
 10e:	90                   	nop
 10f:	90                   	nop

00000110 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	57                   	push   %edi
 114:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 115:	8b 4d 08             	mov    0x8(%ebp),%ecx
 118:	8b 55 10             	mov    0x10(%ebp),%edx
 11b:	8b 45 0c             	mov    0xc(%ebp),%eax
 11e:	89 cb                	mov    %ecx,%ebx
 120:	89 df                	mov    %ebx,%edi
 122:	89 d1                	mov    %edx,%ecx
 124:	fc                   	cld    
 125:	f3 aa                	rep stos %al,%es:(%edi)
 127:	89 ca                	mov    %ecx,%edx
 129:	89 fb                	mov    %edi,%ebx
 12b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 131:	5b                   	pop    %ebx
 132:	5f                   	pop    %edi
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 141:	90                   	nop
 142:	8b 45 0c             	mov    0xc(%ebp),%eax
 145:	0f b6 10             	movzbl (%eax),%edx
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	88 10                	mov    %dl,(%eax)
 14d:	8b 45 08             	mov    0x8(%ebp),%eax
 150:	0f b6 00             	movzbl (%eax),%eax
 153:	84 c0                	test   %al,%al
 155:	0f 95 c0             	setne  %al
 158:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 15c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 160:	84 c0                	test   %al,%al
 162:	75 de                	jne    142 <strcpy+0xd>
    ;
  return os;
 164:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 167:	c9                   	leave  
 168:	c3                   	ret    

00000169 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 169:	55                   	push   %ebp
 16a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 16c:	eb 08                	jmp    176 <strcmp+0xd>
    p++, q++;
 16e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 172:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	0f b6 00             	movzbl (%eax),%eax
 17c:	84 c0                	test   %al,%al
 17e:	74 10                	je     190 <strcmp+0x27>
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	0f b6 10             	movzbl (%eax),%edx
 186:	8b 45 0c             	mov    0xc(%ebp),%eax
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	38 c2                	cmp    %al,%dl
 18e:	74 de                	je     16e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 190:	8b 45 08             	mov    0x8(%ebp),%eax
 193:	0f b6 00             	movzbl (%eax),%eax
 196:	0f b6 d0             	movzbl %al,%edx
 199:	8b 45 0c             	mov    0xc(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	0f b6 c0             	movzbl %al,%eax
 1a2:	89 d1                	mov    %edx,%ecx
 1a4:	29 c1                	sub    %eax,%ecx
 1a6:	89 c8                	mov    %ecx,%eax
}
 1a8:	5d                   	pop    %ebp
 1a9:	c3                   	ret    

000001aa <strlen>:

uint
strlen(char *s)
{
 1aa:	55                   	push   %ebp
 1ab:	89 e5                	mov    %esp,%ebp
 1ad:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b7:	eb 04                	jmp    1bd <strlen+0x13>
 1b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1c0:	03 45 08             	add    0x8(%ebp),%eax
 1c3:	0f b6 00             	movzbl (%eax),%eax
 1c6:	84 c0                	test   %al,%al
 1c8:	75 ef                	jne    1b9 <strlen+0xf>
    ;
  return n;
 1ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1cd:	c9                   	leave  
 1ce:	c3                   	ret    

000001cf <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
 1d2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d5:	8b 45 10             	mov    0x10(%ebp),%eax
 1d8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 1df:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
 1e6:	89 04 24             	mov    %eax,(%esp)
 1e9:	e8 22 ff ff ff       	call   110 <stosb>
  return dst;
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f1:	c9                   	leave  
 1f2:	c3                   	ret    

000001f3 <strchr>:

char*
strchr(const char *s, char c)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	83 ec 04             	sub    $0x4,%esp
 1f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fc:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1ff:	eb 14                	jmp    215 <strchr+0x22>
    if(*s == c)
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	0f b6 00             	movzbl (%eax),%eax
 207:	3a 45 fc             	cmp    -0x4(%ebp),%al
 20a:	75 05                	jne    211 <strchr+0x1e>
      return (char*)s;
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
 20f:	eb 13                	jmp    224 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 211:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	0f b6 00             	movzbl (%eax),%eax
 21b:	84 c0                	test   %al,%al
 21d:	75 e2                	jne    201 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 21f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 224:	c9                   	leave  
 225:	c3                   	ret    

00000226 <gets>:

char*
gets(char *buf, int max)
{
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
 229:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 233:	eb 44                	jmp    279 <gets+0x53>
    cc = read(0, &c, 1);
 235:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 23c:	00 
 23d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 240:	89 44 24 04          	mov    %eax,0x4(%esp)
 244:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 24b:	e8 3c 01 00 00       	call   38c <read>
 250:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 253:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 257:	7e 2d                	jle    286 <gets+0x60>
      break;
    buf[i++] = c;
 259:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25c:	03 45 08             	add    0x8(%ebp),%eax
 25f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 263:	88 10                	mov    %dl,(%eax)
 265:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 269:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26d:	3c 0a                	cmp    $0xa,%al
 26f:	74 16                	je     287 <gets+0x61>
 271:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 275:	3c 0d                	cmp    $0xd,%al
 277:	74 0e                	je     287 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 279:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27c:	83 c0 01             	add    $0x1,%eax
 27f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 282:	7c b1                	jl     235 <gets+0xf>
 284:	eb 01                	jmp    287 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 286:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 287:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28a:	03 45 08             	add    0x8(%ebp),%eax
 28d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 290:	8b 45 08             	mov    0x8(%ebp),%eax
}
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <stat>:

int
stat(char *n, struct stat *st)
{
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a2:	00 
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	89 04 24             	mov    %eax,(%esp)
 2a9:	e8 06 01 00 00       	call   3b4 <open>
 2ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b5:	79 07                	jns    2be <stat+0x29>
    return -1;
 2b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bc:	eb 23                	jmp    2e1 <stat+0x4c>
  r = fstat(fd, st);
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c8:	89 04 24             	mov    %eax,(%esp)
 2cb:	e8 fc 00 00 00       	call   3cc <fstat>
 2d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d6:	89 04 24             	mov    %eax,(%esp)
 2d9:	e8 be 00 00 00       	call   39c <close>
  return r;
 2de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e1:	c9                   	leave  
 2e2:	c3                   	ret    

000002e3 <atoi>:

int
atoi(const char *s)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f0:	eb 23                	jmp    315 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f5:	89 d0                	mov    %edx,%eax
 2f7:	c1 e0 02             	shl    $0x2,%eax
 2fa:	01 d0                	add    %edx,%eax
 2fc:	01 c0                	add    %eax,%eax
 2fe:	89 c2                	mov    %eax,%edx
 300:	8b 45 08             	mov    0x8(%ebp),%eax
 303:	0f b6 00             	movzbl (%eax),%eax
 306:	0f be c0             	movsbl %al,%eax
 309:	01 d0                	add    %edx,%eax
 30b:	83 e8 30             	sub    $0x30,%eax
 30e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 311:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	0f b6 00             	movzbl (%eax),%eax
 31b:	3c 2f                	cmp    $0x2f,%al
 31d:	7e 0a                	jle    329 <atoi+0x46>
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	0f b6 00             	movzbl (%eax),%eax
 325:	3c 39                	cmp    $0x39,%al
 327:	7e c9                	jle    2f2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 329:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32c:	c9                   	leave  
 32d:	c3                   	ret    

0000032e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 32e:	55                   	push   %ebp
 32f:	89 e5                	mov    %esp,%ebp
 331:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33a:	8b 45 0c             	mov    0xc(%ebp),%eax
 33d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 340:	eb 13                	jmp    355 <memmove+0x27>
    *dst++ = *src++;
 342:	8b 45 f8             	mov    -0x8(%ebp),%eax
 345:	0f b6 10             	movzbl (%eax),%edx
 348:	8b 45 fc             	mov    -0x4(%ebp),%eax
 34b:	88 10                	mov    %dl,(%eax)
 34d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 351:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 355:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 359:	0f 9f c0             	setg   %al
 35c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 360:	84 c0                	test   %al,%al
 362:	75 de                	jne    342 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 364:	8b 45 08             	mov    0x8(%ebp),%eax
}
 367:	c9                   	leave  
 368:	c3                   	ret    
 369:	90                   	nop
 36a:	90                   	nop
 36b:	90                   	nop

0000036c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36c:	b8 01 00 00 00       	mov    $0x1,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <exit>:
SYSCALL(exit)
 374:	b8 02 00 00 00       	mov    $0x2,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <wait>:
SYSCALL(wait)
 37c:	b8 03 00 00 00       	mov    $0x3,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <pipe>:
SYSCALL(pipe)
 384:	b8 04 00 00 00       	mov    $0x4,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <read>:
SYSCALL(read)
 38c:	b8 05 00 00 00       	mov    $0x5,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <write>:
SYSCALL(write)
 394:	b8 10 00 00 00       	mov    $0x10,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <close>:
SYSCALL(close)
 39c:	b8 15 00 00 00       	mov    $0x15,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <kill>:
SYSCALL(kill)
 3a4:	b8 06 00 00 00       	mov    $0x6,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <exec>:
SYSCALL(exec)
 3ac:	b8 07 00 00 00       	mov    $0x7,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <open>:
SYSCALL(open)
 3b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <mknod>:
SYSCALL(mknod)
 3bc:	b8 11 00 00 00       	mov    $0x11,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <unlink>:
SYSCALL(unlink)
 3c4:	b8 12 00 00 00       	mov    $0x12,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <fstat>:
SYSCALL(fstat)
 3cc:	b8 08 00 00 00       	mov    $0x8,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <link>:
SYSCALL(link)
 3d4:	b8 13 00 00 00       	mov    $0x13,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <mkdir>:
SYSCALL(mkdir)
 3dc:	b8 14 00 00 00       	mov    $0x14,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <chdir>:
SYSCALL(chdir)
 3e4:	b8 09 00 00 00       	mov    $0x9,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <dup>:
SYSCALL(dup)
 3ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <getpid>:
SYSCALL(getpid)
 3f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <sbrk>:
SYSCALL(sbrk)
 3fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <sleep>:
SYSCALL(sleep)
 404:	b8 0d 00 00 00       	mov    $0xd,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <uptime>:
SYSCALL(uptime)
 40c:	b8 0e 00 00 00       	mov    $0xe,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <halt>:
SYSCALL(halt)
 414:	b8 16 00 00 00       	mov    $0x16,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <clone>:

SYSCALL(clone)
 41c:	b8 19 00 00 00       	mov    $0x19,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <join>:
SYSCALL(join)
 424:	b8 1a 00 00 00       	mov    $0x1a,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <texit>:
SYSCALL(texit)
 42c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <mutex_init>:
SYSCALL(mutex_init)
 434:	b8 1c 00 00 00       	mov    $0x1c,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <mutex_destroy>:
SYSCALL(mutex_destroy)
 43c:	b8 1d 00 00 00       	mov    $0x1d,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <mutex_lock>:
SYSCALL(mutex_lock)
 444:	b8 1e 00 00 00       	mov    $0x1e,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <mutex_unlock>:
 44c:	b8 1f 00 00 00       	mov    $0x1f,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 454:	55                   	push   %ebp
 455:	89 e5                	mov    %esp,%ebp
 457:	83 ec 28             	sub    $0x28,%esp
 45a:	8b 45 0c             	mov    0xc(%ebp),%eax
 45d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 460:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 467:	00 
 468:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46b:	89 44 24 04          	mov    %eax,0x4(%esp)
 46f:	8b 45 08             	mov    0x8(%ebp),%eax
 472:	89 04 24             	mov    %eax,(%esp)
 475:	e8 1a ff ff ff       	call   394 <write>
}
 47a:	c9                   	leave  
 47b:	c3                   	ret    

0000047c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 482:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 489:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 48d:	74 17                	je     4a6 <printint+0x2a>
 48f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 493:	79 11                	jns    4a6 <printint+0x2a>
    neg = 1;
 495:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 49c:	8b 45 0c             	mov    0xc(%ebp),%eax
 49f:	f7 d8                	neg    %eax
 4a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a4:	eb 06                	jmp    4ac <printint+0x30>
  } else {
    x = xx;
 4a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b9:	ba 00 00 00 00       	mov    $0x0,%edx
 4be:	f7 f1                	div    %ecx
 4c0:	89 d0                	mov    %edx,%eax
 4c2:	0f b6 90 64 0d 00 00 	movzbl 0xd64(%eax),%edx
 4c9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4cc:	03 45 f4             	add    -0xc(%ebp),%eax
 4cf:	88 10                	mov    %dl,(%eax)
 4d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 4d5:	8b 55 10             	mov    0x10(%ebp),%edx
 4d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 4db:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4de:	ba 00 00 00 00       	mov    $0x0,%edx
 4e3:	f7 75 d4             	divl   -0x2c(%ebp)
 4e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ed:	75 c4                	jne    4b3 <printint+0x37>
  if(neg)
 4ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f3:	74 2a                	je     51f <printint+0xa3>
    buf[i++] = '-';
 4f5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4f8:	03 45 f4             	add    -0xc(%ebp),%eax
 4fb:	c6 00 2d             	movb   $0x2d,(%eax)
 4fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 502:	eb 1b                	jmp    51f <printint+0xa3>
    putc(fd, buf[i]);
 504:	8d 45 dc             	lea    -0x24(%ebp),%eax
 507:	03 45 f4             	add    -0xc(%ebp),%eax
 50a:	0f b6 00             	movzbl (%eax),%eax
 50d:	0f be c0             	movsbl %al,%eax
 510:	89 44 24 04          	mov    %eax,0x4(%esp)
 514:	8b 45 08             	mov    0x8(%ebp),%eax
 517:	89 04 24             	mov    %eax,(%esp)
 51a:	e8 35 ff ff ff       	call   454 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 51f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 523:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 527:	79 db                	jns    504 <printint+0x88>
    putc(fd, buf[i]);
}
 529:	c9                   	leave  
 52a:	c3                   	ret    

0000052b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 52b:	55                   	push   %ebp
 52c:	89 e5                	mov    %esp,%ebp
 52e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 531:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 538:	8d 45 0c             	lea    0xc(%ebp),%eax
 53b:	83 c0 04             	add    $0x4,%eax
 53e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 541:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 548:	e9 7d 01 00 00       	jmp    6ca <printf+0x19f>
    c = fmt[i] & 0xff;
 54d:	8b 55 0c             	mov    0xc(%ebp),%edx
 550:	8b 45 f0             	mov    -0x10(%ebp),%eax
 553:	01 d0                	add    %edx,%eax
 555:	0f b6 00             	movzbl (%eax),%eax
 558:	0f be c0             	movsbl %al,%eax
 55b:	25 ff 00 00 00       	and    $0xff,%eax
 560:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 563:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 567:	75 2c                	jne    595 <printf+0x6a>
      if(c == '%'){
 569:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56d:	75 0c                	jne    57b <printf+0x50>
        state = '%';
 56f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 576:	e9 4b 01 00 00       	jmp    6c6 <printf+0x19b>
      } else {
        putc(fd, c);
 57b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57e:	0f be c0             	movsbl %al,%eax
 581:	89 44 24 04          	mov    %eax,0x4(%esp)
 585:	8b 45 08             	mov    0x8(%ebp),%eax
 588:	89 04 24             	mov    %eax,(%esp)
 58b:	e8 c4 fe ff ff       	call   454 <putc>
 590:	e9 31 01 00 00       	jmp    6c6 <printf+0x19b>
      }
    } else if(state == '%'){
 595:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 599:	0f 85 27 01 00 00    	jne    6c6 <printf+0x19b>
      if(c == 'd'){
 59f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a3:	75 2d                	jne    5d2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a8:	8b 00                	mov    (%eax),%eax
 5aa:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5b1:	00 
 5b2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5b9:	00 
 5ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 5be:	8b 45 08             	mov    0x8(%ebp),%eax
 5c1:	89 04 24             	mov    %eax,(%esp)
 5c4:	e8 b3 fe ff ff       	call   47c <printint>
        ap++;
 5c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cd:	e9 ed 00 00 00       	jmp    6bf <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 5d2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d6:	74 06                	je     5de <printf+0xb3>
 5d8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5dc:	75 2d                	jne    60b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e1:	8b 00                	mov    (%eax),%eax
 5e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5ea:	00 
 5eb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5f2:	00 
 5f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f7:	8b 45 08             	mov    0x8(%ebp),%eax
 5fa:	89 04 24             	mov    %eax,(%esp)
 5fd:	e8 7a fe ff ff       	call   47c <printint>
        ap++;
 602:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 606:	e9 b4 00 00 00       	jmp    6bf <printf+0x194>
      } else if(c == 's'){
 60b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 60f:	75 46                	jne    657 <printf+0x12c>
        s = (char*)*ap;
 611:	8b 45 e8             	mov    -0x18(%ebp),%eax
 614:	8b 00                	mov    (%eax),%eax
 616:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 619:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 61d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 621:	75 27                	jne    64a <printf+0x11f>
          s = "(null)";
 623:	c7 45 f4 1e 0a 00 00 	movl   $0xa1e,-0xc(%ebp)
        while(*s != 0){
 62a:	eb 1e                	jmp    64a <printf+0x11f>
          putc(fd, *s);
 62c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62f:	0f b6 00             	movzbl (%eax),%eax
 632:	0f be c0             	movsbl %al,%eax
 635:	89 44 24 04          	mov    %eax,0x4(%esp)
 639:	8b 45 08             	mov    0x8(%ebp),%eax
 63c:	89 04 24             	mov    %eax,(%esp)
 63f:	e8 10 fe ff ff       	call   454 <putc>
          s++;
 644:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 648:	eb 01                	jmp    64b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 64a:	90                   	nop
 64b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64e:	0f b6 00             	movzbl (%eax),%eax
 651:	84 c0                	test   %al,%al
 653:	75 d7                	jne    62c <printf+0x101>
 655:	eb 68                	jmp    6bf <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 657:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 65b:	75 1d                	jne    67a <printf+0x14f>
        putc(fd, *ap);
 65d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 660:	8b 00                	mov    (%eax),%eax
 662:	0f be c0             	movsbl %al,%eax
 665:	89 44 24 04          	mov    %eax,0x4(%esp)
 669:	8b 45 08             	mov    0x8(%ebp),%eax
 66c:	89 04 24             	mov    %eax,(%esp)
 66f:	e8 e0 fd ff ff       	call   454 <putc>
        ap++;
 674:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 678:	eb 45                	jmp    6bf <printf+0x194>
      } else if(c == '%'){
 67a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 67e:	75 17                	jne    697 <printf+0x16c>
        putc(fd, c);
 680:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 683:	0f be c0             	movsbl %al,%eax
 686:	89 44 24 04          	mov    %eax,0x4(%esp)
 68a:	8b 45 08             	mov    0x8(%ebp),%eax
 68d:	89 04 24             	mov    %eax,(%esp)
 690:	e8 bf fd ff ff       	call   454 <putc>
 695:	eb 28                	jmp    6bf <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 697:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 69e:	00 
 69f:	8b 45 08             	mov    0x8(%ebp),%eax
 6a2:	89 04 24             	mov    %eax,(%esp)
 6a5:	e8 aa fd ff ff       	call   454 <putc>
        putc(fd, c);
 6aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ad:	0f be c0             	movsbl %al,%eax
 6b0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b4:	8b 45 08             	mov    0x8(%ebp),%eax
 6b7:	89 04 24             	mov    %eax,(%esp)
 6ba:	e8 95 fd ff ff       	call   454 <putc>
      }
      state = 0;
 6bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6c6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6ca:	8b 55 0c             	mov    0xc(%ebp),%edx
 6cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d0:	01 d0                	add    %edx,%eax
 6d2:	0f b6 00             	movzbl (%eax),%eax
 6d5:	84 c0                	test   %al,%al
 6d7:	0f 85 70 fe ff ff    	jne    54d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6dd:	c9                   	leave  
 6de:	c3                   	ret    
 6df:	90                   	nop

000006e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e6:	8b 45 08             	mov    0x8(%ebp),%eax
 6e9:	83 e8 08             	sub    $0x8,%eax
 6ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ef:	a1 88 0d 00 00       	mov    0xd88,%eax
 6f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f7:	eb 24                	jmp    71d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	8b 00                	mov    (%eax),%eax
 6fe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 701:	77 12                	ja     715 <free+0x35>
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 709:	77 24                	ja     72f <free+0x4f>
 70b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70e:	8b 00                	mov    (%eax),%eax
 710:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 713:	77 1a                	ja     72f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 715:	8b 45 fc             	mov    -0x4(%ebp),%eax
 718:	8b 00                	mov    (%eax),%eax
 71a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 71d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 720:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 723:	76 d4                	jbe    6f9 <free+0x19>
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	8b 00                	mov    (%eax),%eax
 72a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72d:	76 ca                	jbe    6f9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 72f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 732:	8b 40 04             	mov    0x4(%eax),%eax
 735:	c1 e0 03             	shl    $0x3,%eax
 738:	89 c2                	mov    %eax,%edx
 73a:	03 55 f8             	add    -0x8(%ebp),%edx
 73d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	39 c2                	cmp    %eax,%edx
 744:	75 24                	jne    76a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 746:	8b 45 f8             	mov    -0x8(%ebp),%eax
 749:	8b 50 04             	mov    0x4(%eax),%edx
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	8b 00                	mov    (%eax),%eax
 751:	8b 40 04             	mov    0x4(%eax),%eax
 754:	01 c2                	add    %eax,%edx
 756:	8b 45 f8             	mov    -0x8(%ebp),%eax
 759:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	8b 00                	mov    (%eax),%eax
 761:	8b 10                	mov    (%eax),%edx
 763:	8b 45 f8             	mov    -0x8(%ebp),%eax
 766:	89 10                	mov    %edx,(%eax)
 768:	eb 0a                	jmp    774 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 76a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76d:	8b 10                	mov    (%eax),%edx
 76f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 772:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 774:	8b 45 fc             	mov    -0x4(%ebp),%eax
 777:	8b 40 04             	mov    0x4(%eax),%eax
 77a:	c1 e0 03             	shl    $0x3,%eax
 77d:	03 45 fc             	add    -0x4(%ebp),%eax
 780:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 783:	75 20                	jne    7a5 <free+0xc5>
    p->s.size += bp->s.size;
 785:	8b 45 fc             	mov    -0x4(%ebp),%eax
 788:	8b 50 04             	mov    0x4(%eax),%edx
 78b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78e:	8b 40 04             	mov    0x4(%eax),%eax
 791:	01 c2                	add    %eax,%edx
 793:	8b 45 fc             	mov    -0x4(%ebp),%eax
 796:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 799:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79c:	8b 10                	mov    (%eax),%edx
 79e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a1:	89 10                	mov    %edx,(%eax)
 7a3:	eb 08                	jmp    7ad <free+0xcd>
  } else
    p->s.ptr = bp;
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7ab:	89 10                	mov    %edx,(%eax)
  freep = p;
 7ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b0:	a3 88 0d 00 00       	mov    %eax,0xd88
}
 7b5:	c9                   	leave  
 7b6:	c3                   	ret    

000007b7 <morecore>:

static Header*
morecore(uint nu)
{
 7b7:	55                   	push   %ebp
 7b8:	89 e5                	mov    %esp,%ebp
 7ba:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7bd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7c4:	77 07                	ja     7cd <morecore+0x16>
    nu = 4096;
 7c6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7cd:	8b 45 08             	mov    0x8(%ebp),%eax
 7d0:	c1 e0 03             	shl    $0x3,%eax
 7d3:	89 04 24             	mov    %eax,(%esp)
 7d6:	e8 21 fc ff ff       	call   3fc <sbrk>
 7db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7de:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7e2:	75 07                	jne    7eb <morecore+0x34>
    return 0;
 7e4:	b8 00 00 00 00       	mov    $0x0,%eax
 7e9:	eb 22                	jmp    80d <morecore+0x56>
  hp = (Header*)p;
 7eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f4:	8b 55 08             	mov    0x8(%ebp),%edx
 7f7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fd:	83 c0 08             	add    $0x8,%eax
 800:	89 04 24             	mov    %eax,(%esp)
 803:	e8 d8 fe ff ff       	call   6e0 <free>
  return freep;
 808:	a1 88 0d 00 00       	mov    0xd88,%eax
}
 80d:	c9                   	leave  
 80e:	c3                   	ret    

0000080f <malloc>:

void*
malloc(uint nbytes)
{
 80f:	55                   	push   %ebp
 810:	89 e5                	mov    %esp,%ebp
 812:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 815:	8b 45 08             	mov    0x8(%ebp),%eax
 818:	83 c0 07             	add    $0x7,%eax
 81b:	c1 e8 03             	shr    $0x3,%eax
 81e:	83 c0 01             	add    $0x1,%eax
 821:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 824:	a1 88 0d 00 00       	mov    0xd88,%eax
 829:	89 45 f0             	mov    %eax,-0x10(%ebp)
 82c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 830:	75 23                	jne    855 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 832:	c7 45 f0 80 0d 00 00 	movl   $0xd80,-0x10(%ebp)
 839:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83c:	a3 88 0d 00 00       	mov    %eax,0xd88
 841:	a1 88 0d 00 00       	mov    0xd88,%eax
 846:	a3 80 0d 00 00       	mov    %eax,0xd80
    base.s.size = 0;
 84b:	c7 05 84 0d 00 00 00 	movl   $0x0,0xd84
 852:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 855:	8b 45 f0             	mov    -0x10(%ebp),%eax
 858:	8b 00                	mov    (%eax),%eax
 85a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	8b 40 04             	mov    0x4(%eax),%eax
 863:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 866:	72 4d                	jb     8b5 <malloc+0xa6>
      if(p->s.size == nunits)
 868:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86b:	8b 40 04             	mov    0x4(%eax),%eax
 86e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 871:	75 0c                	jne    87f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	8b 10                	mov    (%eax),%edx
 878:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87b:	89 10                	mov    %edx,(%eax)
 87d:	eb 26                	jmp    8a5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 87f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 882:	8b 40 04             	mov    0x4(%eax),%eax
 885:	89 c2                	mov    %eax,%edx
 887:	2b 55 ec             	sub    -0x14(%ebp),%edx
 88a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 890:	8b 45 f4             	mov    -0xc(%ebp),%eax
 893:	8b 40 04             	mov    0x4(%eax),%eax
 896:	c1 e0 03             	shl    $0x3,%eax
 899:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8a2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	a3 88 0d 00 00       	mov    %eax,0xd88
      return (void*)(p + 1);
 8ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b0:	83 c0 08             	add    $0x8,%eax
 8b3:	eb 38                	jmp    8ed <malloc+0xde>
    }
    if(p == freep)
 8b5:	a1 88 0d 00 00       	mov    0xd88,%eax
 8ba:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8bd:	75 1b                	jne    8da <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c2:	89 04 24             	mov    %eax,(%esp)
 8c5:	e8 ed fe ff ff       	call   7b7 <morecore>
 8ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d1:	75 07                	jne    8da <malloc+0xcb>
        return 0;
 8d3:	b8 00 00 00 00       	mov    $0x0,%eax
 8d8:	eb 13                	jmp    8ed <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8e8:	e9 70 ff ff ff       	jmp    85d <malloc+0x4e>
}
 8ed:	c9                   	leave  
 8ee:	c3                   	ret    
 8ef:	90                   	nop

000008f0 <pthread_create>:
	clone's 3rd argument, *stek, should be allocated here?
*/

#define PAGESIZE (4096)  //Maybe 4092??

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void*), void *arg){
 8f0:	55                   	push   %ebp
 8f1:	89 e5                	mov    %esp,%ebp
 8f3:	83 ec 28             	sub    $0x28,%esp

	void *mystek = malloc((uint)PAGESIZE*2); //Why do we need the *2?
 8f6:	c7 04 24 00 20 00 00 	movl   $0x2000,(%esp)
 8fd:	e8 0d ff ff ff       	call   80f <malloc>
 902:	89 45 f4             	mov    %eax,-0xc(%ebp)
//zzddhhtjzz/xv6/blob/master
	if((uint)mystek % PAGESIZE){
 905:	8b 45 f4             	mov    -0xc(%ebp),%eax
 908:	25 ff 0f 00 00       	and    $0xfff,%eax
 90d:	85 c0                	test   %eax,%eax
 90f:	74 15                	je     926 <pthread_create+0x36>
		mystek += 4096 - ((uint)mystek % PAGESIZE);
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	89 c2                	mov    %eax,%edx
 916:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 91c:	b8 00 10 00 00       	mov    $0x1000,%eax
 921:	29 d0                	sub    %edx,%eax
 923:	01 45 f4             	add    %eax,-0xc(%ebp)
	}
	thread->pid = clone(start_routine, arg, mystek);
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	89 44 24 08          	mov    %eax,0x8(%esp)
 92d:	8b 45 14             	mov    0x14(%ebp),%eax
 930:	89 44 24 04          	mov    %eax,0x4(%esp)
 934:	8b 45 10             	mov    0x10(%ebp),%eax
 937:	89 04 24             	mov    %eax,(%esp)
 93a:	e8 dd fa ff ff       	call   41c <clone>
 93f:	8b 55 08             	mov    0x8(%ebp),%edx
 942:	89 02                	mov    %eax,(%edx)
	return thread->pid;
 944:	8b 45 08             	mov    0x8(%ebp),%eax
 947:	8b 00                	mov    (%eax),%eax
}
 949:	c9                   	leave  
 94a:	c3                   	ret    

0000094b <pthread_join>:

int pthread_join(pthread_t thread, void **retval){
 94b:	55                   	push   %ebp
 94c:	89 e5                	mov    %esp,%ebp
 94e:	83 ec 28             	sub    $0x28,%esp

	void *stek;

	join((int)thread.pid, &stek, (void*)retval);
 951:	8b 45 08             	mov    0x8(%ebp),%eax
 954:	8b 55 0c             	mov    0xc(%ebp),%edx
 957:	89 54 24 08          	mov    %edx,0x8(%esp)
 95b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 95e:	89 54 24 04          	mov    %edx,0x4(%esp)
 962:	89 04 24             	mov    %eax,(%esp)
 965:	e8 ba fa ff ff       	call   424 <join>

	free(stek);
 96a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96d:	89 04 24             	mov    %eax,(%esp)
 970:	e8 6b fd ff ff       	call   6e0 <free>

	return 0;
 975:	b8 00 00 00 00       	mov    $0x0,%eax
}
 97a:	c9                   	leave  
 97b:	c3                   	ret    

0000097c <pthread_exit>:

int pthread_exit(void *retval){
 97c:	55                   	push   %ebp
 97d:	89 e5                	mov    %esp,%ebp
 97f:	83 ec 18             	sub    $0x18,%esp

	texit(retval);
 982:	8b 45 08             	mov    0x8(%ebp),%eax
 985:	89 04 24             	mov    %eax,(%esp)
 988:	e8 9f fa ff ff       	call   42c <texit>

	return 0;
 98d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 992:	c9                   	leave  
 993:	c3                   	ret    

00000994 <pthread_mutex_init>:


int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr_t *attr){
 994:	55                   	push   %ebp
 995:	89 e5                	mov    %esp,%ebp
 997:	83 ec 18             	sub    $0x18,%esp

	int mid = mutex_init();
 99a:	e8 95 fa ff ff       	call   434 <mutex_init>
 99f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//returns the id of the initalized mutex
	return mid;
 9a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 9a5:	c9                   	leave  
 9a6:	c3                   	ret    

000009a7 <pthread_mutex_destroy>:


int pthread_mutex_destroy(pthread_mutex_t *mutex){
 9a7:	55                   	push   %ebp
 9a8:	89 e5                	mov    %esp,%ebp
 9aa:	83 ec 18             	sub    $0x18,%esp

	//flag this mutex as destroyed
	mutex_destroy(mutex->mid);
 9ad:	8b 45 08             	mov    0x8(%ebp),%eax
 9b0:	8b 40 04             	mov    0x4(%eax),%eax
 9b3:	89 04 24             	mov    %eax,(%esp)
 9b6:	e8 81 fa ff ff       	call   43c <mutex_destroy>
	return 0;
 9bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 9c0:	c9                   	leave  
 9c1:	c3                   	ret    

000009c2 <pthread_mutex_lock>:


int pthread_mutex_lock(pthread_mutex_t *mutex){
 9c2:	55                   	push   %ebp
 9c3:	89 e5                	mov    %esp,%ebp
 9c5:	83 ec 18             	sub    $0x18,%esp

	mutex_lock(mutex->mid);
 9c8:	8b 45 08             	mov    0x8(%ebp),%eax
 9cb:	8b 40 04             	mov    0x4(%eax),%eax
 9ce:	89 04 24             	mov    %eax,(%esp)
 9d1:	e8 6e fa ff ff       	call   444 <mutex_lock>
	return 0;
 9d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 9db:	c9                   	leave  
 9dc:	c3                   	ret    

000009dd <pthread_mutex_unlock>:


int pthread_mutex_unlock(pthread_mutex_t *mutex){
 9dd:	55                   	push   %ebp
 9de:	89 e5                	mov    %esp,%ebp
 9e0:	83 ec 18             	sub    $0x18,%esp

	mutex_unlock(mutex->mid);
 9e3:	8b 45 08             	mov    0x8(%ebp),%eax
 9e6:	8b 40 04             	mov    0x4(%eax),%eax
 9e9:	89 04 24             	mov    %eax,(%esp)
 9ec:	e8 5b fa ff ff       	call   44c <mutex_unlock>
	return 0;
 9f1:	b8 00 00 00 00       	mov    $0x0,%eax
 9f6:	c9                   	leave  
 9f7:	c3                   	ret    
