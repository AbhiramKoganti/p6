
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "ptentry.h"

#define PGSIZE 4096

int main(void) {
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 34             	sub    $0x34,%esp
    const uint PAGES_NUM = 100;
  15:	c7 45 f0 64 00 00 00 	movl   $0x64,-0x10(%ebp)
    // Allocate one pages of space
    char *buffer = sbrk(PGSIZE * sizeof(char));
  1c:	83 ec 0c             	sub    $0xc,%esp
  1f:	68 00 10 00 00       	push   $0x1000
  24:	e8 61 04 00 00       	call   48a <sbrk>
  29:	83 c4 10             	add    $0x10,%esp
  2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    char *sp = buffer - PGSIZE;
  2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  32:	2d 00 10 00 00       	sub    $0x1000,%eax
  37:	89 45 e8             	mov    %eax,-0x18(%ebp)
    char *boundary = buffer - 2 * PGSIZE;
  3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  3d:	2d 00 20 00 00       	sub    $0x2000,%eax
  42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *text = 0x0;
  45:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    uint text_pages = (uint) boundary / PGSIZE;
  4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  4f:	c1 e8 0c             	shr    $0xc,%eax
  52:	89 45 dc             	mov    %eax,-0x24(%ebp)
    struct pt_entry pt_entries[PAGES_NUM];
  55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  58:	83 e8 01             	sub    $0x1,%eax
  5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  61:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  68:	b8 10 00 00 00       	mov    $0x10,%eax
  6d:	83 e8 01             	sub    $0x1,%eax
  70:	01 d0                	add    %edx,%eax
  72:	b9 10 00 00 00       	mov    $0x10,%ecx
  77:	ba 00 00 00 00       	mov    $0x0,%edx
  7c:	f7 f1                	div    %ecx
  7e:	6b c0 10             	imul   $0x10,%eax,%eax
  81:	89 c2                	mov    %eax,%edx
  83:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  89:	89 e1                	mov    %esp,%ecx
  8b:	29 d1                	sub    %edx,%ecx
  8d:	89 ca                	mov    %ecx,%edx
  8f:	39 d4                	cmp    %edx,%esp
  91:	74 10                	je     a3 <main+0xa3>
  93:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  99:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  a0:	00 
  a1:	eb ec                	jmp    8f <main+0x8f>
  a3:	89 c2                	mov    %eax,%edx
  a5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  ab:	29 d4                	sub    %edx,%esp
  ad:	89 c2                	mov    %eax,%edx
  af:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  b5:	85 d2                	test   %edx,%edx
  b7:	74 0d                	je     c6 <main+0xc6>
  b9:	25 ff 0f 00 00       	and    $0xfff,%eax
  be:	83 e8 04             	sub    $0x4,%eax
  c1:	01 e0                	add    %esp,%eax
  c3:	83 08 00             	orl    $0x0,(%eax)
  c6:	89 e0                	mov    %esp,%eax
  c8:	83 c0 03             	add    $0x3,%eax
  cb:	c1 e8 02             	shr    $0x2,%eax
  ce:	c1 e0 02             	shl    $0x2,%eax
  d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    sbrk(PAGES_NUM * PGSIZE);
  d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  d7:	c1 e0 0c             	shl    $0xc,%eax
  da:	83 ec 0c             	sub    $0xc,%esp
  dd:	50                   	push   %eax
  de:	e8 a7 03 00 00       	call   48a <sbrk>
  e3:	83 c4 10             	add    $0x10,%esp

    for (int i = 0; i < text_pages; i++)
  e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ed:	eb 23                	jmp    112 <main+0x112>
        text[i * PGSIZE] = text[i * PGSIZE];
  ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f2:	c1 e0 0c             	shl    $0xc,%eax
  f5:	89 c2                	mov    %eax,%edx
  f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  fa:	01 d0                	add    %edx,%eax
  fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ff:	c1 e2 0c             	shl    $0xc,%edx
 102:	89 d1                	mov    %edx,%ecx
 104:	8b 55 e0             	mov    -0x20(%ebp),%edx
 107:	01 ca                	add    %ecx,%edx
 109:	0f b6 00             	movzbl (%eax),%eax
 10c:	88 02                	mov    %al,(%edx)
    for (int i = 0; i < text_pages; i++)
 10e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 112:	8b 45 f4             	mov    -0xc(%ebp),%eax
 115:	39 45 dc             	cmp    %eax,-0x24(%ebp)
 118:	77 d5                	ja     ef <main+0xef>
    sp[0] = sp[0];
 11a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 11d:	0f b6 10             	movzbl (%eax),%edx
 120:	8b 45 e8             	mov    -0x18(%ebp),%eax
 123:	88 10                	mov    %dl,(%eax)
    buffer[0] = buffer[0];
 125:	8b 45 ec             	mov    -0x14(%ebp),%eax
 128:	0f b6 10             	movzbl (%eax),%edx
 12b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 12e:	88 10                	mov    %dl,(%eax)
    int expected_pages_num = (uint)buffer / PGSIZE;
 130:	8b 45 ec             	mov    -0x14(%ebp),%eax
 133:	c1 e8 0c             	shr    $0xc,%eax
 136:	89 45 d0             	mov    %eax,-0x30(%ebp)


    int retval = getpgtable(pt_entries, 100, 1);
 139:	83 ec 04             	sub    $0x4,%esp
 13c:	6a 01                	push   $0x1
 13e:	6a 64                	push   $0x64
 140:	ff 75 d4             	pushl  -0x2c(%ebp)
 143:	e8 62 03 00 00       	call   4aa <getpgtable>
 148:	83 c4 10             	add    $0x10,%esp
 14b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if (retval != expected_pages_num) {
 14e:	8b 45 cc             	mov    -0x34(%ebp),%eax
 151:	3b 45 d0             	cmp    -0x30(%ebp),%eax
 154:	74 1a                	je     170 <main+0x170>
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", expected_pages_num, retval);
 156:	ff 75 cc             	pushl  -0x34(%ebp)
 159:	ff 75 d0             	pushl  -0x30(%ebp)
 15c:	68 60 09 00 00       	push   $0x960
 161:	6a 01                	push   $0x1
 163:	e8 2e 04 00 00       	call   596 <printf>
 168:	83 c4 10             	add    $0x10,%esp
        exit();
 16b:	e8 92 02 00 00       	call   402 <exit>
    }
    printf(1, "XV6_TEST_OUTPUT PASS!\n");
 170:	83 ec 08             	sub    $0x8,%esp
 173:	68 ab 09 00 00       	push   $0x9ab
 178:	6a 01                	push   $0x1
 17a:	e8 17 04 00 00       	call   596 <printf>
 17f:	83 c4 10             	add    $0x10,%esp
    exit();
 182:	e8 7b 02 00 00       	call   402 <exit>

00000187 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 187:	55                   	push   %ebp
 188:	89 e5                	mov    %esp,%ebp
 18a:	57                   	push   %edi
 18b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 18c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 18f:	8b 55 10             	mov    0x10(%ebp),%edx
 192:	8b 45 0c             	mov    0xc(%ebp),%eax
 195:	89 cb                	mov    %ecx,%ebx
 197:	89 df                	mov    %ebx,%edi
 199:	89 d1                	mov    %edx,%ecx
 19b:	fc                   	cld    
 19c:	f3 aa                	rep stos %al,%es:(%edi)
 19e:	89 ca                	mov    %ecx,%edx
 1a0:	89 fb                	mov    %edi,%ebx
 1a2:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1a5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1a8:	90                   	nop
 1a9:	5b                   	pop    %ebx
 1aa:	5f                   	pop    %edi
 1ab:	5d                   	pop    %ebp
 1ac:	c3                   	ret    

000001ad <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 1ad:	f3 0f 1e fb          	endbr32 
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1bd:	90                   	nop
 1be:	8b 55 0c             	mov    0xc(%ebp),%edx
 1c1:	8d 42 01             	lea    0x1(%edx),%eax
 1c4:	89 45 0c             	mov    %eax,0xc(%ebp)
 1c7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ca:	8d 48 01             	lea    0x1(%eax),%ecx
 1cd:	89 4d 08             	mov    %ecx,0x8(%ebp)
 1d0:	0f b6 12             	movzbl (%edx),%edx
 1d3:	88 10                	mov    %dl,(%eax)
 1d5:	0f b6 00             	movzbl (%eax),%eax
 1d8:	84 c0                	test   %al,%al
 1da:	75 e2                	jne    1be <strcpy+0x11>
    ;
  return os;
 1dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1df:	c9                   	leave  
 1e0:	c3                   	ret    

000001e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e1:	f3 0f 1e fb          	endbr32 
 1e5:	55                   	push   %ebp
 1e6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1e8:	eb 08                	jmp    1f2 <strcmp+0x11>
    p++, q++;
 1ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	0f b6 00             	movzbl (%eax),%eax
 1f8:	84 c0                	test   %al,%al
 1fa:	74 10                	je     20c <strcmp+0x2b>
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	0f b6 10             	movzbl (%eax),%edx
 202:	8b 45 0c             	mov    0xc(%ebp),%eax
 205:	0f b6 00             	movzbl (%eax),%eax
 208:	38 c2                	cmp    %al,%dl
 20a:	74 de                	je     1ea <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
 20f:	0f b6 00             	movzbl (%eax),%eax
 212:	0f b6 d0             	movzbl %al,%edx
 215:	8b 45 0c             	mov    0xc(%ebp),%eax
 218:	0f b6 00             	movzbl (%eax),%eax
 21b:	0f b6 c0             	movzbl %al,%eax
 21e:	29 c2                	sub    %eax,%edx
 220:	89 d0                	mov    %edx,%eax
}
 222:	5d                   	pop    %ebp
 223:	c3                   	ret    

00000224 <strlen>:

uint
strlen(const char *s)
{
 224:	f3 0f 1e fb          	endbr32 
 228:	55                   	push   %ebp
 229:	89 e5                	mov    %esp,%ebp
 22b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 22e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 235:	eb 04                	jmp    23b <strlen+0x17>
 237:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 23b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	01 d0                	add    %edx,%eax
 243:	0f b6 00             	movzbl (%eax),%eax
 246:	84 c0                	test   %al,%al
 248:	75 ed                	jne    237 <strlen+0x13>
    ;
  return n;
 24a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 24d:	c9                   	leave  
 24e:	c3                   	ret    

0000024f <memset>:

void*
memset(void *dst, int c, uint n)
{
 24f:	f3 0f 1e fb          	endbr32 
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 256:	8b 45 10             	mov    0x10(%ebp),%eax
 259:	50                   	push   %eax
 25a:	ff 75 0c             	pushl  0xc(%ebp)
 25d:	ff 75 08             	pushl  0x8(%ebp)
 260:	e8 22 ff ff ff       	call   187 <stosb>
 265:	83 c4 0c             	add    $0xc,%esp
  return dst;
 268:	8b 45 08             	mov    0x8(%ebp),%eax
}
 26b:	c9                   	leave  
 26c:	c3                   	ret    

0000026d <strchr>:

char*
strchr(const char *s, char c)
{
 26d:	f3 0f 1e fb          	endbr32 
 271:	55                   	push   %ebp
 272:	89 e5                	mov    %esp,%ebp
 274:	83 ec 04             	sub    $0x4,%esp
 277:	8b 45 0c             	mov    0xc(%ebp),%eax
 27a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 27d:	eb 14                	jmp    293 <strchr+0x26>
    if(*s == c)
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	0f b6 00             	movzbl (%eax),%eax
 285:	38 45 fc             	cmp    %al,-0x4(%ebp)
 288:	75 05                	jne    28f <strchr+0x22>
      return (char*)s;
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	eb 13                	jmp    2a2 <strchr+0x35>
  for(; *s; s++)
 28f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	0f b6 00             	movzbl (%eax),%eax
 299:	84 c0                	test   %al,%al
 29b:	75 e2                	jne    27f <strchr+0x12>
  return 0;
 29d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2a2:	c9                   	leave  
 2a3:	c3                   	ret    

000002a4 <gets>:

char*
gets(char *buf, int max)
{
 2a4:	f3 0f 1e fb          	endbr32 
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2b5:	eb 42                	jmp    2f9 <gets+0x55>
    cc = read(0, &c, 1);
 2b7:	83 ec 04             	sub    $0x4,%esp
 2ba:	6a 01                	push   $0x1
 2bc:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2bf:	50                   	push   %eax
 2c0:	6a 00                	push   $0x0
 2c2:	e8 53 01 00 00       	call   41a <read>
 2c7:	83 c4 10             	add    $0x10,%esp
 2ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2d1:	7e 33                	jle    306 <gets+0x62>
      break;
    buf[i++] = c;
 2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d6:	8d 50 01             	lea    0x1(%eax),%edx
 2d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2dc:	89 c2                	mov    %eax,%edx
 2de:	8b 45 08             	mov    0x8(%ebp),%eax
 2e1:	01 c2                	add    %eax,%edx
 2e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2e7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2e9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2ed:	3c 0a                	cmp    $0xa,%al
 2ef:	74 16                	je     307 <gets+0x63>
 2f1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2f5:	3c 0d                	cmp    $0xd,%al
 2f7:	74 0e                	je     307 <gets+0x63>
  for(i=0; i+1 < max; ){
 2f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fc:	83 c0 01             	add    $0x1,%eax
 2ff:	39 45 0c             	cmp    %eax,0xc(%ebp)
 302:	7f b3                	jg     2b7 <gets+0x13>
 304:	eb 01                	jmp    307 <gets+0x63>
      break;
 306:	90                   	nop
      break;
  }
  buf[i] = '\0';
 307:	8b 55 f4             	mov    -0xc(%ebp),%edx
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	01 d0                	add    %edx,%eax
 30f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 312:	8b 45 08             	mov    0x8(%ebp),%eax
}
 315:	c9                   	leave  
 316:	c3                   	ret    

00000317 <stat>:

int
stat(const char *n, struct stat *st)
{
 317:	f3 0f 1e fb          	endbr32 
 31b:	55                   	push   %ebp
 31c:	89 e5                	mov    %esp,%ebp
 31e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 321:	83 ec 08             	sub    $0x8,%esp
 324:	6a 00                	push   $0x0
 326:	ff 75 08             	pushl  0x8(%ebp)
 329:	e8 14 01 00 00       	call   442 <open>
 32e:	83 c4 10             	add    $0x10,%esp
 331:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 334:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 338:	79 07                	jns    341 <stat+0x2a>
    return -1;
 33a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 33f:	eb 25                	jmp    366 <stat+0x4f>
  r = fstat(fd, st);
 341:	83 ec 08             	sub    $0x8,%esp
 344:	ff 75 0c             	pushl  0xc(%ebp)
 347:	ff 75 f4             	pushl  -0xc(%ebp)
 34a:	e8 0b 01 00 00       	call   45a <fstat>
 34f:	83 c4 10             	add    $0x10,%esp
 352:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 355:	83 ec 0c             	sub    $0xc,%esp
 358:	ff 75 f4             	pushl  -0xc(%ebp)
 35b:	e8 ca 00 00 00       	call   42a <close>
 360:	83 c4 10             	add    $0x10,%esp
  return r;
 363:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 366:	c9                   	leave  
 367:	c3                   	ret    

00000368 <atoi>:

int
atoi(const char *s)
{
 368:	f3 0f 1e fb          	endbr32 
 36c:	55                   	push   %ebp
 36d:	89 e5                	mov    %esp,%ebp
 36f:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 372:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 379:	eb 25                	jmp    3a0 <atoi+0x38>
    n = n*10 + *s++ - '0';
 37b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 37e:	89 d0                	mov    %edx,%eax
 380:	c1 e0 02             	shl    $0x2,%eax
 383:	01 d0                	add    %edx,%eax
 385:	01 c0                	add    %eax,%eax
 387:	89 c1                	mov    %eax,%ecx
 389:	8b 45 08             	mov    0x8(%ebp),%eax
 38c:	8d 50 01             	lea    0x1(%eax),%edx
 38f:	89 55 08             	mov    %edx,0x8(%ebp)
 392:	0f b6 00             	movzbl (%eax),%eax
 395:	0f be c0             	movsbl %al,%eax
 398:	01 c8                	add    %ecx,%eax
 39a:	83 e8 30             	sub    $0x30,%eax
 39d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3a0:	8b 45 08             	mov    0x8(%ebp),%eax
 3a3:	0f b6 00             	movzbl (%eax),%eax
 3a6:	3c 2f                	cmp    $0x2f,%al
 3a8:	7e 0a                	jle    3b4 <atoi+0x4c>
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
 3ad:	0f b6 00             	movzbl (%eax),%eax
 3b0:	3c 39                	cmp    $0x39,%al
 3b2:	7e c7                	jle    37b <atoi+0x13>
  return n;
 3b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b7:	c9                   	leave  
 3b8:	c3                   	ret    

000003b9 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b9:	f3 0f 1e fb          	endbr32 
 3bd:	55                   	push   %ebp
 3be:	89 e5                	mov    %esp,%ebp
 3c0:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3cf:	eb 17                	jmp    3e8 <memmove+0x2f>
    *dst++ = *src++;
 3d1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3d4:	8d 42 01             	lea    0x1(%edx),%eax
 3d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
 3da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3dd:	8d 48 01             	lea    0x1(%eax),%ecx
 3e0:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3e3:	0f b6 12             	movzbl (%edx),%edx
 3e6:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3e8:	8b 45 10             	mov    0x10(%ebp),%eax
 3eb:	8d 50 ff             	lea    -0x1(%eax),%edx
 3ee:	89 55 10             	mov    %edx,0x10(%ebp)
 3f1:	85 c0                	test   %eax,%eax
 3f3:	7f dc                	jg     3d1 <memmove+0x18>
  return vdst;
 3f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f8:	c9                   	leave  
 3f9:	c3                   	ret    

000003fa <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3fa:	b8 01 00 00 00       	mov    $0x1,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <exit>:
SYSCALL(exit)
 402:	b8 02 00 00 00       	mov    $0x2,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <wait>:
SYSCALL(wait)
 40a:	b8 03 00 00 00       	mov    $0x3,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <pipe>:
SYSCALL(pipe)
 412:	b8 04 00 00 00       	mov    $0x4,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <read>:
SYSCALL(read)
 41a:	b8 05 00 00 00       	mov    $0x5,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <write>:
SYSCALL(write)
 422:	b8 10 00 00 00       	mov    $0x10,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <close>:
SYSCALL(close)
 42a:	b8 15 00 00 00       	mov    $0x15,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <kill>:
SYSCALL(kill)
 432:	b8 06 00 00 00       	mov    $0x6,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <exec>:
SYSCALL(exec)
 43a:	b8 07 00 00 00       	mov    $0x7,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <open>:
SYSCALL(open)
 442:	b8 0f 00 00 00       	mov    $0xf,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <mknod>:
SYSCALL(mknod)
 44a:	b8 11 00 00 00       	mov    $0x11,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <unlink>:
SYSCALL(unlink)
 452:	b8 12 00 00 00       	mov    $0x12,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <fstat>:
SYSCALL(fstat)
 45a:	b8 08 00 00 00       	mov    $0x8,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <link>:
SYSCALL(link)
 462:	b8 13 00 00 00       	mov    $0x13,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <mkdir>:
SYSCALL(mkdir)
 46a:	b8 14 00 00 00       	mov    $0x14,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <chdir>:
SYSCALL(chdir)
 472:	b8 09 00 00 00       	mov    $0x9,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <dup>:
SYSCALL(dup)
 47a:	b8 0a 00 00 00       	mov    $0xa,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <getpid>:
SYSCALL(getpid)
 482:	b8 0b 00 00 00       	mov    $0xb,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <sbrk>:
SYSCALL(sbrk)
 48a:	b8 0c 00 00 00       	mov    $0xc,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <sleep>:
SYSCALL(sleep)
 492:	b8 0d 00 00 00       	mov    $0xd,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <uptime>:
SYSCALL(uptime)
 49a:	b8 0e 00 00 00       	mov    $0xe,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <mencrypt>:
SYSCALL(mencrypt)
 4a2:	b8 16 00 00 00       	mov    $0x16,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <getpgtable>:
SYSCALL(getpgtable)
 4aa:	b8 17 00 00 00       	mov    $0x17,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret    

000004b2 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 4b2:	b8 18 00 00 00       	mov    $0x18,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret    

000004ba <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4ba:	f3 0f 1e fb          	endbr32 
 4be:	55                   	push   %ebp
 4bf:	89 e5                	mov    %esp,%ebp
 4c1:	83 ec 18             	sub    $0x18,%esp
 4c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c7:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4ca:	83 ec 04             	sub    $0x4,%esp
 4cd:	6a 01                	push   $0x1
 4cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4d2:	50                   	push   %eax
 4d3:	ff 75 08             	pushl  0x8(%ebp)
 4d6:	e8 47 ff ff ff       	call   422 <write>
 4db:	83 c4 10             	add    $0x10,%esp
}
 4de:	90                   	nop
 4df:	c9                   	leave  
 4e0:	c3                   	ret    

000004e1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e1:	f3 0f 1e fb          	endbr32 
 4e5:	55                   	push   %ebp
 4e6:	89 e5                	mov    %esp,%ebp
 4e8:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4f2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4f6:	74 17                	je     50f <printint+0x2e>
 4f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4fc:	79 11                	jns    50f <printint+0x2e>
    neg = 1;
 4fe:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 505:	8b 45 0c             	mov    0xc(%ebp),%eax
 508:	f7 d8                	neg    %eax
 50a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 50d:	eb 06                	jmp    515 <printint+0x34>
  } else {
    x = xx;
 50f:	8b 45 0c             	mov    0xc(%ebp),%eax
 512:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 515:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 51c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 51f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 522:	ba 00 00 00 00       	mov    $0x0,%edx
 527:	f7 f1                	div    %ecx
 529:	89 d1                	mov    %edx,%ecx
 52b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52e:	8d 50 01             	lea    0x1(%eax),%edx
 531:	89 55 f4             	mov    %edx,-0xc(%ebp)
 534:	0f b6 91 10 0c 00 00 	movzbl 0xc10(%ecx),%edx
 53b:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 53f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 542:	8b 45 ec             	mov    -0x14(%ebp),%eax
 545:	ba 00 00 00 00       	mov    $0x0,%edx
 54a:	f7 f1                	div    %ecx
 54c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 54f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 553:	75 c7                	jne    51c <printint+0x3b>
  if(neg)
 555:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 559:	74 2d                	je     588 <printint+0xa7>
    buf[i++] = '-';
 55b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55e:	8d 50 01             	lea    0x1(%eax),%edx
 561:	89 55 f4             	mov    %edx,-0xc(%ebp)
 564:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 569:	eb 1d                	jmp    588 <printint+0xa7>
    putc(fd, buf[i]);
 56b:	8d 55 dc             	lea    -0x24(%ebp),%edx
 56e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 571:	01 d0                	add    %edx,%eax
 573:	0f b6 00             	movzbl (%eax),%eax
 576:	0f be c0             	movsbl %al,%eax
 579:	83 ec 08             	sub    $0x8,%esp
 57c:	50                   	push   %eax
 57d:	ff 75 08             	pushl  0x8(%ebp)
 580:	e8 35 ff ff ff       	call   4ba <putc>
 585:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 588:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 58c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 590:	79 d9                	jns    56b <printint+0x8a>
}
 592:	90                   	nop
 593:	90                   	nop
 594:	c9                   	leave  
 595:	c3                   	ret    

00000596 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 596:	f3 0f 1e fb          	endbr32 
 59a:	55                   	push   %ebp
 59b:	89 e5                	mov    %esp,%ebp
 59d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5a7:	8d 45 0c             	lea    0xc(%ebp),%eax
 5aa:	83 c0 04             	add    $0x4,%eax
 5ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5b7:	e9 59 01 00 00       	jmp    715 <printf+0x17f>
    c = fmt[i] & 0xff;
 5bc:	8b 55 0c             	mov    0xc(%ebp),%edx
 5bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c2:	01 d0                	add    %edx,%eax
 5c4:	0f b6 00             	movzbl (%eax),%eax
 5c7:	0f be c0             	movsbl %al,%eax
 5ca:	25 ff 00 00 00       	and    $0xff,%eax
 5cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5d2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d6:	75 2c                	jne    604 <printf+0x6e>
      if(c == '%'){
 5d8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5dc:	75 0c                	jne    5ea <printf+0x54>
        state = '%';
 5de:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5e5:	e9 27 01 00 00       	jmp    711 <printf+0x17b>
      } else {
        putc(fd, c);
 5ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ed:	0f be c0             	movsbl %al,%eax
 5f0:	83 ec 08             	sub    $0x8,%esp
 5f3:	50                   	push   %eax
 5f4:	ff 75 08             	pushl  0x8(%ebp)
 5f7:	e8 be fe ff ff       	call   4ba <putc>
 5fc:	83 c4 10             	add    $0x10,%esp
 5ff:	e9 0d 01 00 00       	jmp    711 <printf+0x17b>
      }
    } else if(state == '%'){
 604:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 608:	0f 85 03 01 00 00    	jne    711 <printf+0x17b>
      if(c == 'd'){
 60e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 612:	75 1e                	jne    632 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 614:	8b 45 e8             	mov    -0x18(%ebp),%eax
 617:	8b 00                	mov    (%eax),%eax
 619:	6a 01                	push   $0x1
 61b:	6a 0a                	push   $0xa
 61d:	50                   	push   %eax
 61e:	ff 75 08             	pushl  0x8(%ebp)
 621:	e8 bb fe ff ff       	call   4e1 <printint>
 626:	83 c4 10             	add    $0x10,%esp
        ap++;
 629:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 62d:	e9 d8 00 00 00       	jmp    70a <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 632:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 636:	74 06                	je     63e <printf+0xa8>
 638:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 63c:	75 1e                	jne    65c <printf+0xc6>
        printint(fd, *ap, 16, 0);
 63e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 641:	8b 00                	mov    (%eax),%eax
 643:	6a 00                	push   $0x0
 645:	6a 10                	push   $0x10
 647:	50                   	push   %eax
 648:	ff 75 08             	pushl  0x8(%ebp)
 64b:	e8 91 fe ff ff       	call   4e1 <printint>
 650:	83 c4 10             	add    $0x10,%esp
        ap++;
 653:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 657:	e9 ae 00 00 00       	jmp    70a <printf+0x174>
      } else if(c == 's'){
 65c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 660:	75 43                	jne    6a5 <printf+0x10f>
        s = (char*)*ap;
 662:	8b 45 e8             	mov    -0x18(%ebp),%eax
 665:	8b 00                	mov    (%eax),%eax
 667:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 66a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 66e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 672:	75 25                	jne    699 <printf+0x103>
          s = "(null)";
 674:	c7 45 f4 c2 09 00 00 	movl   $0x9c2,-0xc(%ebp)
        while(*s != 0){
 67b:	eb 1c                	jmp    699 <printf+0x103>
          putc(fd, *s);
 67d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 680:	0f b6 00             	movzbl (%eax),%eax
 683:	0f be c0             	movsbl %al,%eax
 686:	83 ec 08             	sub    $0x8,%esp
 689:	50                   	push   %eax
 68a:	ff 75 08             	pushl  0x8(%ebp)
 68d:	e8 28 fe ff ff       	call   4ba <putc>
 692:	83 c4 10             	add    $0x10,%esp
          s++;
 695:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 699:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69c:	0f b6 00             	movzbl (%eax),%eax
 69f:	84 c0                	test   %al,%al
 6a1:	75 da                	jne    67d <printf+0xe7>
 6a3:	eb 65                	jmp    70a <printf+0x174>
        }
      } else if(c == 'c'){
 6a5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6a9:	75 1d                	jne    6c8 <printf+0x132>
        putc(fd, *ap);
 6ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ae:	8b 00                	mov    (%eax),%eax
 6b0:	0f be c0             	movsbl %al,%eax
 6b3:	83 ec 08             	sub    $0x8,%esp
 6b6:	50                   	push   %eax
 6b7:	ff 75 08             	pushl  0x8(%ebp)
 6ba:	e8 fb fd ff ff       	call   4ba <putc>
 6bf:	83 c4 10             	add    $0x10,%esp
        ap++;
 6c2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6c6:	eb 42                	jmp    70a <printf+0x174>
      } else if(c == '%'){
 6c8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6cc:	75 17                	jne    6e5 <printf+0x14f>
        putc(fd, c);
 6ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d1:	0f be c0             	movsbl %al,%eax
 6d4:	83 ec 08             	sub    $0x8,%esp
 6d7:	50                   	push   %eax
 6d8:	ff 75 08             	pushl  0x8(%ebp)
 6db:	e8 da fd ff ff       	call   4ba <putc>
 6e0:	83 c4 10             	add    $0x10,%esp
 6e3:	eb 25                	jmp    70a <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6e5:	83 ec 08             	sub    $0x8,%esp
 6e8:	6a 25                	push   $0x25
 6ea:	ff 75 08             	pushl  0x8(%ebp)
 6ed:	e8 c8 fd ff ff       	call   4ba <putc>
 6f2:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6f8:	0f be c0             	movsbl %al,%eax
 6fb:	83 ec 08             	sub    $0x8,%esp
 6fe:	50                   	push   %eax
 6ff:	ff 75 08             	pushl  0x8(%ebp)
 702:	e8 b3 fd ff ff       	call   4ba <putc>
 707:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 70a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 711:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 715:	8b 55 0c             	mov    0xc(%ebp),%edx
 718:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71b:	01 d0                	add    %edx,%eax
 71d:	0f b6 00             	movzbl (%eax),%eax
 720:	84 c0                	test   %al,%al
 722:	0f 85 94 fe ff ff    	jne    5bc <printf+0x26>
    }
  }
}
 728:	90                   	nop
 729:	90                   	nop
 72a:	c9                   	leave  
 72b:	c3                   	ret    

0000072c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 72c:	f3 0f 1e fb          	endbr32 
 730:	55                   	push   %ebp
 731:	89 e5                	mov    %esp,%ebp
 733:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 736:	8b 45 08             	mov    0x8(%ebp),%eax
 739:	83 e8 08             	sub    $0x8,%eax
 73c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73f:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 744:	89 45 fc             	mov    %eax,-0x4(%ebp)
 747:	eb 24                	jmp    76d <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 751:	72 12                	jb     765 <free+0x39>
 753:	8b 45 f8             	mov    -0x8(%ebp),%eax
 756:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 759:	77 24                	ja     77f <free+0x53>
 75b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75e:	8b 00                	mov    (%eax),%eax
 760:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 763:	72 1a                	jb     77f <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 765:	8b 45 fc             	mov    -0x4(%ebp),%eax
 768:	8b 00                	mov    (%eax),%eax
 76a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 76d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 770:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 773:	76 d4                	jbe    749 <free+0x1d>
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	8b 00                	mov    (%eax),%eax
 77a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 77d:	73 ca                	jae    749 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 77f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 782:	8b 40 04             	mov    0x4(%eax),%eax
 785:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 78c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78f:	01 c2                	add    %eax,%edx
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	8b 00                	mov    (%eax),%eax
 796:	39 c2                	cmp    %eax,%edx
 798:	75 24                	jne    7be <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 79a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79d:	8b 50 04             	mov    0x4(%eax),%edx
 7a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a3:	8b 00                	mov    (%eax),%eax
 7a5:	8b 40 04             	mov    0x4(%eax),%eax
 7a8:	01 c2                	add    %eax,%edx
 7aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ad:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b3:	8b 00                	mov    (%eax),%eax
 7b5:	8b 10                	mov    (%eax),%edx
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	89 10                	mov    %edx,(%eax)
 7bc:	eb 0a                	jmp    7c8 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 7be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c1:	8b 10                	mov    (%eax),%edx
 7c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	8b 40 04             	mov    0x4(%eax),%eax
 7ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d8:	01 d0                	add    %edx,%eax
 7da:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7dd:	75 20                	jne    7ff <free+0xd3>
    p->s.size += bp->s.size;
 7df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e2:	8b 50 04             	mov    0x4(%eax),%edx
 7e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e8:	8b 40 04             	mov    0x4(%eax),%eax
 7eb:	01 c2                	add    %eax,%edx
 7ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f6:	8b 10                	mov    (%eax),%edx
 7f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fb:	89 10                	mov    %edx,(%eax)
 7fd:	eb 08                	jmp    807 <free+0xdb>
  } else
    p->s.ptr = bp;
 7ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 802:	8b 55 f8             	mov    -0x8(%ebp),%edx
 805:	89 10                	mov    %edx,(%eax)
  freep = p;
 807:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80a:	a3 2c 0c 00 00       	mov    %eax,0xc2c
}
 80f:	90                   	nop
 810:	c9                   	leave  
 811:	c3                   	ret    

00000812 <morecore>:

static Header*
morecore(uint nu)
{
 812:	f3 0f 1e fb          	endbr32 
 816:	55                   	push   %ebp
 817:	89 e5                	mov    %esp,%ebp
 819:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 81c:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 823:	77 07                	ja     82c <morecore+0x1a>
    nu = 4096;
 825:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 82c:	8b 45 08             	mov    0x8(%ebp),%eax
 82f:	c1 e0 03             	shl    $0x3,%eax
 832:	83 ec 0c             	sub    $0xc,%esp
 835:	50                   	push   %eax
 836:	e8 4f fc ff ff       	call   48a <sbrk>
 83b:	83 c4 10             	add    $0x10,%esp
 83e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 841:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 845:	75 07                	jne    84e <morecore+0x3c>
    return 0;
 847:	b8 00 00 00 00       	mov    $0x0,%eax
 84c:	eb 26                	jmp    874 <morecore+0x62>
  hp = (Header*)p;
 84e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 851:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 854:	8b 45 f0             	mov    -0x10(%ebp),%eax
 857:	8b 55 08             	mov    0x8(%ebp),%edx
 85a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 85d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 860:	83 c0 08             	add    $0x8,%eax
 863:	83 ec 0c             	sub    $0xc,%esp
 866:	50                   	push   %eax
 867:	e8 c0 fe ff ff       	call   72c <free>
 86c:	83 c4 10             	add    $0x10,%esp
  return freep;
 86f:	a1 2c 0c 00 00       	mov    0xc2c,%eax
}
 874:	c9                   	leave  
 875:	c3                   	ret    

00000876 <malloc>:

void*
malloc(uint nbytes)
{
 876:	f3 0f 1e fb          	endbr32 
 87a:	55                   	push   %ebp
 87b:	89 e5                	mov    %esp,%ebp
 87d:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 880:	8b 45 08             	mov    0x8(%ebp),%eax
 883:	83 c0 07             	add    $0x7,%eax
 886:	c1 e8 03             	shr    $0x3,%eax
 889:	83 c0 01             	add    $0x1,%eax
 88c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 88f:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 894:	89 45 f0             	mov    %eax,-0x10(%ebp)
 897:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 89b:	75 23                	jne    8c0 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 89d:	c7 45 f0 24 0c 00 00 	movl   $0xc24,-0x10(%ebp)
 8a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a7:	a3 2c 0c 00 00       	mov    %eax,0xc2c
 8ac:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 8b1:	a3 24 0c 00 00       	mov    %eax,0xc24
    base.s.size = 0;
 8b6:	c7 05 28 0c 00 00 00 	movl   $0x0,0xc28
 8bd:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c3:	8b 00                	mov    (%eax),%eax
 8c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cb:	8b 40 04             	mov    0x4(%eax),%eax
 8ce:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8d1:	77 4d                	ja     920 <malloc+0xaa>
      if(p->s.size == nunits)
 8d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d6:	8b 40 04             	mov    0x4(%eax),%eax
 8d9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8dc:	75 0c                	jne    8ea <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 8de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e1:	8b 10                	mov    (%eax),%edx
 8e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e6:	89 10                	mov    %edx,(%eax)
 8e8:	eb 26                	jmp    910 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 8ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ed:	8b 40 04             	mov    0x4(%eax),%eax
 8f0:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8f3:	89 c2                	mov    %eax,%edx
 8f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f8:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	8b 40 04             	mov    0x4(%eax),%eax
 901:	c1 e0 03             	shl    $0x3,%eax
 904:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 907:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 90d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 910:	8b 45 f0             	mov    -0x10(%ebp),%eax
 913:	a3 2c 0c 00 00       	mov    %eax,0xc2c
      return (void*)(p + 1);
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	83 c0 08             	add    $0x8,%eax
 91e:	eb 3b                	jmp    95b <malloc+0xe5>
    }
    if(p == freep)
 920:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 925:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 928:	75 1e                	jne    948 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 92a:	83 ec 0c             	sub    $0xc,%esp
 92d:	ff 75 ec             	pushl  -0x14(%ebp)
 930:	e8 dd fe ff ff       	call   812 <morecore>
 935:	83 c4 10             	add    $0x10,%esp
 938:	89 45 f4             	mov    %eax,-0xc(%ebp)
 93b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 93f:	75 07                	jne    948 <malloc+0xd2>
        return 0;
 941:	b8 00 00 00 00       	mov    $0x0,%eax
 946:	eb 13                	jmp    95b <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 948:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 94e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 951:	8b 00                	mov    (%eax),%eax
 953:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 956:	e9 6d ff ff ff       	jmp    8c8 <malloc+0x52>
  }
}
 95b:	c9                   	leave  
 95c:	c3                   	ret    
