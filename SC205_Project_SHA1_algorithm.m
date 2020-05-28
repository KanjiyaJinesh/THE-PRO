%  SHA-1 Algorithm

inp = input('Give some input : ','s');
inp=double(inp)                              % double fun. convert character into it's ASCII value & form a new array
messagebits=encode(inp)                      %encode function will give o/p which is multiple of 512

% Initializing A,B,C,D,E.
A=[0 1 1 0 0 1 1 1 0 1 0 0 0 1 0 1 0 0 1 0 0 0 1 1 0 0 0 0 0 0 0 1];    % A=[67452301] <- this is in hexadecimal
B=[1 1 1 0 1 1 1 1 1 1 0 0 1 1 0 1 1 0 1 0 1 0 1 1 1 0 0 0 1 0 0 1];   % B=[efcdab89]
C=[1 0 0 1 1 0 0 0 1 0 1 1 1 0 1 0 1 1 0 1 1 1 0 0 1 1 1 1 1 1 1 0];   % C=[98badcfe]
D=[0 0 0 1 0 0 0 0 0 0 1 1 0 0 1 0 0 1 0 1 0 1 0 0 0 1 1 1 0 1 1 0];   % D=[10325476]
E=[1 1 0 0 0 0 1 1 1 1 0 1 0 0 1 0 1 1 1 0 0 0 0 1 1 1 1 1 0 0 0 0];   % e=[c3d2e1f0]

size=length(messagebits);
nn=1;
for n=1:512:size
   W=zeros(80,32);
   j=1;
   for i=nn:(nn+15)
       W(j,:)=messagebits((((i-1)*32)+1):(i*32));
       j=j+1;
   end
   for i=17:80
       temp=XOR_of_four(W(i-3,:),W(i-8,:),W(i-14,:),W(i-16,:));
       W(i,:)=left_rotate(temp,1);
   end
   a=A;
   b=B;
   c=C;
   d=D;
   e=E;
   
   for i=1:80
       if i>=1 && i<=20
           F = OR_of_three( AND(b,c) , AND(NOT(b),d) , zeros(1,32));
           k=[0 1 0 1 1 0 1 0 1 0 0 0 0 0 1 0 0 1 1 1 1 0 0 1 1 0 0 1 1 0 0 1];    % k=[5A827999] <- this is in hexadecimal
       
       elseif i>=21 && i<=40
           F = XOR_of_four(b,c,d,zeros(1,32));
           k=[0 1 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 1 0 1 0 1 1 1 0 1 0 0 0 0 1];    %k=[6ED9EBA1]
           
       elseif i>=41 && i<=60
           F = OR_of_three( AND(b,c) , AND(b,d) , AND(c,d));
           k=[1 0 0 0 1 1 1 1 0 0 0 1 1 0 1 1 1 0 1 1 1 1 0 0 1 1 0 1 1 1 0 0];    % k=[8F1BBCDC]
           
       elseif i>=61 && i<=80
           F = XOR_of_four(b,c,d,zeros(1,32));
           k=[1 1 0 0 1 0 1 0 0 1 1 0 0 0 1 0 1 1 0 0 0 0 0 1 1 1 0 1 0 1 1 0];    % k=[CA62C1D6]
       end
       
       temp=ADD_of_five(left_rotate(a,5),F,e,k,W(i,:));
       e=d;
       d=c;
       c=left_rotate(b,30);
       b=a;
       a=temp;
   end
   A=ADD_of_two(A,a);
   B=ADD_of_two(B,b);
   C=ADD_of_two(C,c);
   D=ADD_of_two(D,d);
   E=ADD_of_two(E,e);
   
   nn=nn+16;
end
disp(A);
disp(B);
disp(C);
disp(D);
disp(E);
digest=get_digest([A B C D E]);
disp('The digest is ');
disp(digest);

%% All Function

function messagebits=encode(input_array)
    len=length(input_array);
    messagebits=[];
    for i=1:len                           % this for loop will convert input into array of binary-bits of length 8 each
        a=input_array(1,i);
        anss=[];
        while a~=0
            h=mod(a,2);
            anss = [anss h];
            a=floor(a/2);
        end
        anss=flip(anss);
        l=length(anss);
        if l~=8
           anss=[zeros(1,8-l) anss]; 
        end
        messagebits=[messagebits anss];
    end
    messagebits=[messagebits 1]           % 1 is added at end of messagebits
    while mod(length(messagebits),512)~=448     %  zeros are added at the end of messagebits till 
       messagebits=[messagebits 0];               %  length of mesagebits will be in form of {512(n)+448}
    end
    l=len*8;
    a=l;
    ml=[];
    while a~=0
        h=mod(a,2);
        ml = [ml h];
        a=floor(a/2);
    end
    ml=[ml zeros(1,64-length(ml))];        % total 64 bits in addition with converting length of
    ml=flip(ml);                              % inputbits in binary 
    messagebits=[messagebits ml];            %append ml at the end of messagebits.
end

function A=left_rotate(A,n)                   % function for left rotate A.
    temp=A(1:n);
    A(1:32-n)=A(n+1:32);
    A(33-n:32)=temp;
end

function A=XOR_of_four(a,b,c,d)              % function for XOR operation of four variables a,b,c,d 
    A=zeros(1,32);
    for i=1:32
       A(1,i)=mod(a(1,i)+b(1,i)+c(1,i)+d(1,i),2);
    end
end

function A=AND(a,b)                           % function for AND operation of a and b
    A=zeros(1,32);
    for i=1:32
       if a(1,i)==1 && b(1,i)==1 
           A(1,i)=1;
       else
           A(1,i)=0;
       end
    end
end

function A=OR_of_three(a,b,c)                 % function for OR operation of three variables a,b,c
    A=zeros(1,32);
    for i=1:32
       if a(1,i)==0 && b(1,i)==0 && c(1,i)==0 
           A(1,i)=0;
       else
           A(1,i)=1;
       end
    end
end

function a=NOT(a)                             % function for NOT operation
    for i=1:32
       a(1,i)=mod(a(1,i)+1 , 2); 
    end
end

function A=ADD_of_two(a,b)                    % function for ADD operation of two variable a,b
    A=zeros(1,32);
    carry=0;
    for i=32:-1:1
        sum=carry + a(1,i) + b(1,i);
        if mod(sum,2)==0
            A(1,i)=0;
            carry=sum/2;
        else
            A(1,i)=1;
            carry=(sum-1)/2;
        end
    
    end
end

function A=ADD_of_five(a,b,c,d,e)             % function for ADD operation of five variables a,b,c,d,e
    A=zeros(1,32);
    carry=0;
    for i=32:-1:1
        sum=carry + a(1,i) + b(1,i) + c(1,i) + d(1,i) + e(1,i);
        if mod(sum,2)==0
            A(1,i)=0;
            carry=sum/2;
        else
            A(1,i)=1;
            carry=(sum-1)/2;
        end
    
    end
end

function d=get_digest(a)
    d='';
    for i=1:4:160
       an=a(1,i)*8 + a(1,i+1)*4 + a(1,i+2)*2 + a(1,i+3);
       if an<=9
           an=num2str(an);
       elseif an==10
           an='a';
       elseif an==11
           an='b';
       elseif an==12
           an='c';
       elseif an==13
           an='d';
       elseif an==14
           an='e';
       elseif an==15
           an='f';
       end
       d=strcat(d,an);  
    end
end