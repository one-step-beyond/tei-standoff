function createCanvasOverlay(color, zIndex, container, canvasId) {
        div = container;

        var canvas = document.createElement("canvas");
        canvas.id=canvasId;
        canvas.style.zIndex = zIndex; 

        canvas.style.left=0;
        canvas.style.top=0;

        canvas.style.position = "absolute";
        canvas.style.overflow = "visible";

        canvas.width=div.scrollWidth;        
        canvas.height=div.scrollHeight;    

    var context=canvas.getContext('2d');
      context.fillStyle = color;
      context.fillRect(0,0, canvas.width, canvas.height);


        div.appendChild(canvas);
        return canvas;
 }
 
 function drawOverlayBoxes(canvas, container, data, color) {
 
    var context=canvas.getContext('2d');

      var cnv = container.getClientRects();
      var offset_x=cnv[0].left;
      var offset_y=cnv[0].top;
 
      context.strokeStyle=color;  // set line color
     
              for (j=0; j<data.length; j++) {
                 var elem_list = data[j].fragment;
                 for (k=0; k < elem_list.length; k++) {
                     if(elem_list[k].id) {
                     var brects = document.getElementById(elem_list[k].id).getClientRects();
                     for (l=0; l < brects.length; l++) 
                     {
           context.beginPath();
            context.rect(
                               brects[l].left-offset_x,
                               brects[l].top-offset_y,
                               brects[l].right-brects[l].left,
                               brects[l].bottom-brects[l].top
                               );
           context.stroke();
                     }
                     }
                 }
           }
 }