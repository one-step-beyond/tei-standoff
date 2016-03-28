/**
 * Code to create dynamic canvas above all other element in a html page.
 * F. Permadi, 2009
 * http://www.permadi.com 
 *
 * This code is made available for educational purpose comes with no warranty.  Use at your own risk.
 */
var myCanvas;

 function createCanvasOverlay(color, canvasContainer)
 {
    if (!myCanvas)
    {
      if (!canvasContainer)
      {
        canvasContainer = document.createElement('div'); 
        document.body.appendChild(canvasContainer);
        canvasContainer.style.position="absolute";
        canvasContainer.style.left="0px";
        canvasContainer.style.top="0px";
        canvasContainer.style.width="100%";
        canvasContainer.style.height="100%";
        canvasContainer.style.zIndex="1000";
        superContainer=document.body;
      }
      else
        superContainer=canvasContainer;
      
      // Part of block below is inspired by code from Google excanvas.js
      {
      myCanvas = document.createElement('canvas');    
      myCanvas.style.width = superContainer.scrollWidth+"px";
      myCanvas.style.height = superContainer.scrollHeight+"px";
      // You must set this otherwise the canvas will be streethed to fit the container
      myCanvas.width=superContainer.scrollWidth;
      myCanvas.height=superContainer.scrollHeight;    
      //surfaceElement.style.width=window.innerWidth; 
      myCanvas.style.overflow = 'visible';
      myCanvas.style.position = 'absolute';
      }
      
      var context=myCanvas.getContext('2d');
      context.fillStyle = color;
      context.fillRect(0,0, myCanvas.width, myCanvas.height);
      canvasContainer.appendChild(myCanvas);
  
      var closeButton=document.createElement('div');
      closeButton.style.position="relative";      
      closeButton.style.float="right";
      closeButton.onclick = hideCanvas;
      closeButton.style.left="20px";
      closeButton.style.top="14px";      
      closeButton.style.width="50px";
      closeButton.style.height="20px";
      closeButton.style.background="#f00";
      closeButtonText=document.createTextNode("CLOSE");
      closeButton.appendChild(closeButtonText);
      
      canvasContainer.appendChild(closeButton);
     
     
//draw boxes around all .alfa elements
//this is just for starters
//ultimately I'd be drawing boxes around stretches of text between and including two elements
    var elems = $('.alfa');
    var coords ='coo \n';
    for (i=0; i < elems.length; i++) {
 
          rects=elems[i].getClientRects();
          
          for(j=0; j< rects.length; j++ ) {
         coords += + i + ': top = ' + elems[i].offsetTop 
            + ' left = ' + elems[i].offsetLeft
            + ' width = ' + elems[i].offsetWidth 
            +  ' height = ' + elems[i].offsetHeight 
            + '\n';
            context.beginPath();
            context.rect(
                               rects[j].left,
                               rects[j].top,
                               rects[j].right-rects[j].left,
                               rects[j].bottom-rects[j].top
                               );
           context.stroke();
           }
           
   }
   
   drawLayerBoxes('pname');
   
     
     
      context.strokeStyle='rgb(0,255,0)';  // a green line
      context.lineWidth=4;                 // 4 pixels thickness     
      myCanvas.parentNode.addEventListener('mousemove', onMouseMoveOnMyCanvas, false); 
      myCanvas.parentNode.addEventListener('mousedown', onMouseClickOnMyCanvas, false); 
      //alert(myCanvas);
    }
    else
      myCanvas.parentNode.style.visibility='visible';

      
 }
 
 function drawLayerBoxes(layer) {
      var context=myCanvas.getContext('2d');
      context.strokeStyle='rgb(0,0,255)';  // a green line
              for (j=0; j<dane.length; j++) {
                 //each data row.fragment contains a continuous stretch of elements that should be unified where boxes fall on one line)
                 var elem_list = dane[j].fragment;
                 
                 var boxes = {};
                 
                 for (k=0; k < elem_list.length; k++) {
                     if(elem_list[k].id) {
                     var rects = document.getElementById(elem_list[k].id).getClientRects();
                     for (l=0; l < rects.length; l++) 
                     {
                     var topbot= rects[l].top + ',' + rects[l].bottom;
                     var left= rects[l].left;
                     var right= rects[l].right;
                     var marr=boxes[topbot];
                     if(marr) {
                     var a = marr.lr.length;
                     marr.lr.push([left, right]); 
                     //window.alert('add marr' + topbot + 'bef '+ a + ' val ' + marr.lr.length);
                     } else {
                     //window.alert('new marr ' + topbot);
                     marr={"top": rects[l].top, "bottom": rects[l].bottom, "lr": [[left, right]]};
                     } 
                      boxes[topbot]=marr;

                                           
                      context.strokeStyle='rgb(0,0,255)';  // a green line
           context.beginPath();
            context.rect(
                               rects[l].left,
                               rects[l].top,
                               rects[l].right-rects[l].left,
                               rects[l].bottom-rects[l].top
                               );
           context.stroke();
                         
                     }
                     }
                     
                      
                 }
                 
                   context.strokeStyle='rgb(255,0,255)';  // a pink
                        context.beginPath();
                        
                         for(var i in boxes) {
                     
                         context.rect(
                              boxes[i].lr[0][0],
                              boxes[i].top,
                              boxes[i].lr[boxes[i].lr.length-1][1]-boxes[i].lr[0][0],
                              boxes[i].bottom-boxes[i].top
                                   );
                                              context.stroke();
                                               

                     }
                     
               /*
               window.alert(' pname ' + j + ' ' + sid + 'coords' + sstartx + ' ' + sstarty + ' -- ' + sendx + ', ' + sendy +
               ' ' + eid + 'coords' + estartx + ', ' + estarty + ' -- ' + eendx + ', ' + eendy );
               */
               
               
           }

//
     
 }
 
  function onMouseMoveOnMyCanvas(event)
  {
    if (myCanvas.drawing)
    {  
      var mouseX=event.layerX;  
      var mouseY=event.layerY;

      var context = myCanvas.getContext("2d");
      if (myCanvas.pathBegun==false)
      {
        context.beginPath();
        myCanvas.pathBegun=true;
      }
      else
      {
        context.lineTo(mouseX, mouseY);
        context.stroke();
      }
    }
  }

  function onMouseClickOnMyCanvas(event)
  {
    myCanvas.drawing=!myCanvas.drawing;
    // reset the path when starting over
    if (myCanvas.drawing)
      myCanvas.pathBegun=false;
  }
 
 function hideCanvas()
 {
    if (myCanvas)
    {
      myCanvas.parentNode.style.visibility='hidden';
    }
 }