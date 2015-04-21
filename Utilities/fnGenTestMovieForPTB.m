fig=figure(1);
clf;
aviobj = avifile('example30fps.avi','fps',30);
for k=1:10*30
    cla
    text(0.2,0.5,sprintf('%d,%d',floor(k/30),k),'FontSize',61);
    drawnow
    G=getframe();
    G.cdata = imresize(G.cdata,[480 640 ]);
    aviobj = addframe(aviobj,G);
end
aviobj = close(aviobj);

close(fig)
