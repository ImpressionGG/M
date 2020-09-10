% run

   fps=20;
   frames=100;
   M=moviein(frames);
   x=0:0.001:1;
   set(gca,'NextPlot','replacechildren');
   for i=1:frames
       y=sin(2*pi*i/25)*x.^2;
       plot(x,y);
       title('i');
       xlabel('x');
       ylabel('y');
       axis([0 1 -2 2]);
       M(:,i)=getframe;
   end
   movie(M,3,fps)
   movie2avi(M,'AVITest','fps',fps,'Compression', 'none');

%eof   