<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="SchemaVisualiser.Visualization" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

              <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
             <!-- Bootstrap Core JavaScript -->
        <script type="text/javascript" src="Scripts/bootstrap/bower_components/bootstrap/dist/js/bootstrap.min.js"></script>

       <!-- Bootstrap Core CSS -->
        <link href="Scripts/bootstrap/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet"/>

   

        <script type="text/javascript" src="Scripts/vivagraph.min.js"></script>

         <link rel="stylesheet" type="text/css" href="Styles/tooltip.css"/>
        <script type='text/javascript'>
            var renderer;
            var resumeAnimation = true;
            var rotDeg_Clockwise = 0;
            var rotDeg_CounterClockwise = 0;

            /*global Viva, $*/
            function Play() {
              if (resumeAnimation == true) {
                    renderer.resume();
                    //Display stop icon
                    document.getElementById('playBtn').value = "\u25A0";
                    resumeAnimation = false;    
                
                }
                else {
                    renderer.pause();
                    //Display play icon
                    document.getElementById('playBtn').value = "\u25B6";
                    resumeAnimation = true;
                }

            }
            function RotateClockWise() {
                if (rotDeg_CounterClockwise != 0) {
                    rotDeg_Clockwise = rotDeg_CounterClockwise + 10;
                    rotDeg_CounterClockwise = 0;
                }
                else
                    rotDeg_Clockwise = rotDeg_Clockwise + 10;

                var rotate = "rotate(" + rotDeg_Clockwise + "deg)";
                $('#graph1').css('transform', rotate); // here point at same id, but could be any other selecteur if you wish
                $('#graph1').css('-webkit-transform', rotate); // here point at same id, but could be any other selecteur if you wish
                $('#graph1').css('-ms-transform', rotate); // here point at same id, but could be any other selecteur if you wish      
            }
            function RotateCounterClockWise() {
                if (rotDeg_Clockwise != 0) {
                    rotDeg_CounterClockwise = rotDeg_Clockwise - 10;
                    rotDeg_Clockwise = 0;
                }
                else {
                    rotDeg_CounterClockwise = rotDeg_CounterClockwise - 10;

                }
                var rotate = "rotate(" + rotDeg_CounterClockwise + "deg)";
                $('#graph1').css('transform', rotate); // here point at same id, but could be any other selecteur if you wish
                $('#graph1').css('-webkit-transform', rotate); // here point at same id, but could be any other selecteur if you wish
                $('#graph1').css('-ms-transform', rotate); // here point at same id, but could be any other selecteur if you wish      
            }
            function onLoad() {
                var jsonString = document.getElementById('txtJson').value;
                var data = JSON.parse(jsonString);  
                var d3Sample = function () {
                    var graph = Viva.Graph.graph();
                    graph.Name = "Schema Visualisation";

                    for (var i = 0; i < data.nodes.length; ++i) {
                        graph.addNode(i, data.nodes[i]);
                    }

                    for (i = 0; i < data.links.length; ++i) {
                        var link = data.links[i];
                        graph.addLink(link.source, link.target, link.value);
                    }

                    return graph;
                };
                //Colors for the 9 categories
                var colors = [
                        "#4183D7", "#000099",
                        "#BFBFBF", "#26A65B",
                        "#674172", "#8E44AD",
                        "#F89406", "#AEA8D3",
                        "#F64747"];
                var categories = ["Science & Technology", "Arts & Entertainment", "Sports", "Society", "Products & Services", "Transportation", "Time & Space", "Special Interests", "Commons"];
                var example = function () {
                    var graph = d3Sample();

                    var layout = Viva.Graph.Layout.forceDirected(graph, {
                        springLength: 30,
                        springCoeff: 0.0008,
                        dragCoeff: 0.09,
                        gravity: -1.2,
                        theta: 0.8
                    });

                    var svgGraphics = Viva.Graph.View.svgGraphics(),
                    // we use this method to highlight all realted links
                    // when user hovers mouse over a node:
                highlightRelatedNodes = function (nodeId, isOn) {
                    // just enumerate all realted nodes and update link color:
                    graph.forEachLinkedNode(nodeId, function (node, link) {
                        var linkUI = svgGraphics.getLinkUI(link.id);
                        if (linkUI) {
                            // linkUI is a UI object created by graphics below
                            linkUI.attr('stroke', isOn ? '#CF000F' : 'url(#myLinearGradient1)');
                        }
                    });
                };
                    svgGraphics.node(function (node) {
                        var groupId = node.data.groupId;
                        var radius = 0;
                        if (node.id == 1976)//Topic
                            radius = 48;
                        else if (node.id == 1001)//Person
                            radius = 24;
                        else if (node.id == 216)//Location
                            radius = 24;
                        else
                            radius = 7;
                        var circle = Viva.Graph.svg('circle')
                            .attr('r', radius)
                            .attr('stroke', '#fff')
                            .attr('stroke-width', '1.5px')
                            .attr("fill", colors[groupId - 1]);

                        // circle.append('title').text(node.data.Name);
                        $(circle).hover(function () { // mouse over
                            //Showing Tooltip
                            var nodeName = data.nodes[node.id - 1].Name;
                            var position = layout.getNodePosition(node.id);
                            var tool = document.getElementById('hoverToolTip');
                            var matrix = this.getScreenCTM().translate(this.getAttribute("cx"), this.getAttribute("cy"));
                            tool.style.left = matrix.e + "px";
                            tool.style.top = matrix.f + "px";
                            tool.innerHTML = nodeName;
                            tool.style.display = "block";
                            //Highlighting related nodes
                            highlightRelatedNodes(node.id, true);
                            document.body.style.cursor = "pointer";
                        }, function () { // mouse out
                            var tool = document.getElementById('hoverToolTip');
                            tool.innerHTML = "";
                            tool.style.display = "none";
                            //Unhighlighting related nodes
                            highlightRelatedNodes(node.id, false);
                            document.body.style.cursor = "default";
                        });

                        $(circle).click(function () { // mouse click
                            document.getElementById('spanTypeName').innerHTML = data.nodes[node.id-1].Name;
                            document.getElementById('spanInstCount').innerHTML = data.nodes[node.id-1].InstanceCount;
                            document.getElementById('spanDomain').innerHTML = data.nodes[node.id-1].ParentDomain;
                            document.getElementById('spanCategory').innerHTML = categories[data.nodes[node.id - 1].groupId - 1];
                            $('#myModal').modal('toggle');
                        });
                        return circle;

                    }).placeNode(function (nodeUI, pos) {
                        nodeUI.attr("cx", pos.x).attr("cy", pos.y);
                    });

                    svgGraphics.link(function (link) {
                        return Viva.Graph.svg('line')
                     .attr('stroke', 'url(#myLinearGradient1)')
                     .attr('stroke-width', Math.sqrt(link.data));
                    });


                    renderer = Viva.Graph.View.renderer(graph, {
                        container: document.getElementById('graph1'),
                        layout: layout,
                        graphics: svgGraphics,
                        prerender: true,
                        prerender: 50,
                        renderLinks: true

                    });

                    renderer.run(500);
                    renderer.pause();

                    var graphics = renderer.getGraphics();
                    $('.zoom').click(function (e) {
                        e.preventDefault();
                        if ($(this).hasClass('in')) {
                            renderer.zoomIn();
                        } else {
                            renderer.zoomOut();
                        }
                    });


                } ();
            }
        </script>
        <style type='text/css'>
            #graph1{
                position: absolute;
                vertical-align:middle;
                width: 100%;
                height: 100%;
            }
            #graph1 > svg {
                width: 100%;
                height: 100%;
 
            }
            #leftPanel
            {
            margin:0;
            height:100%;
            background-color:#303030;
            color:White;
            opacity:0.8;
            font-size:12px;
            }
            #leftPanel input
            {
             padding-left: 4px;
            color:#303030;  
                width: 25px;
    height: 25px;
    margin-top:2px;
    font-size: 14px;    
            }
            #leftPanel table
            {
            margin-left:auto;
            margin-right:auto;
            margin-top:10px;    
            } 
            
             #leftPanel table:last-child
             {
                 margin-left:11%;
             }
  
        </style>

</head>
    <body onload='onLoad()' style="width:100%; height: 100%; position : absolute">
          <form id="form1" runat="server" style="width:100%;height: 100%">
             <!-- Modal -->
  <!-- Modal -->
  <div class="modal fade" id="myModal" role="dialog">
    <div class="modal-dialog modal-sm">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">&times;</button>
          <h4 class="modal-title">Selected Node Info</h4>
        </div>
        <div class="modal-body">
        <table>
      <tr><td><strong>Type Name:</strong></td><td style="padding-left:10px"><span id="spanTypeName"></span></td></tr>
      <tr><td><strong>Instance Count:</strong></td><td style="padding-left:10px"><span id="spanInstCount"></span></td></tr>
      <tr><td><strong>Parent Domain:</strong></td><td style="padding-left:10px"><span id="spanDomain"></span></td></tr>
      <tr><td><strong>Category:</strong></td><td style="padding-left:10px"><span id="spanCategory"></span></td></tr>
       </table>
        </div>
      </div>
    </div>
  </div>
            <div id="wrapper"  style="width:100%;height: 100%">
      
     <div id="page-wrapper" style="width:100%;height: 100%;background-color:#FFFFE0;margin:0px;border:none;">


      <div class="row" style="height:100%;padding:0">
      <!--left-side panel-->
      <div  class="col-lg-2" style="width:11%;z-index:10000;height:100%;padding:0">
      <div id="leftPanel" >
        <span style="font-weight:bold;margin-left:14%;font-size:1.6em;font-family:Georgia, serif">
    Schemapher
    </span>
   <!-- Graph controls-->
    <table>
    <tr>
    <td><input class='zoom out' type="button" value="-" title="Zoom Out"/></td>
    <td></td>
    <td><input class='zoom in' type="button" value="+" title="Zoom in"/></td>
    </tr>
    <tr>
    <td></td>
    <td><input type="button" id="playBtn" onclick="Play();" value="&#9658" title="Play/Pause Animation"/></td>
    <td></td>
    </tr>
    <tr>
    <td><input  type="button" value="&#x21B6;" title="Rotate Counter Clockwise" onclick="RotateCounterClockWise()"/> </td>
    <td></td>
    <td><input  type="button" value="&#x21B7;" title="Rotate Clockwise" onclick="RotateClockWise()"/></td>
    </tr>
    </table>
    
    <table>
    <tr>
    <td colspan="2"><b>Graph Summary</b></td>
    </tr>
    <tr>
    <td># Nodes:</td>
    <td>
        <asp:Label ID="lblNodesCount" runat="server" Text="[Nodes Count]"></asp:Label>   
    </td>
    </tr>
    <tr>
    <td># Links:</td>
    <td>
        <asp:Label ID="lblLinksCount" runat="server" Text="[Links Count]"></asp:Label>    
    </td>
    </tr>
    </table>
      <table>
      <tr>
      <td style="background-color:#4183D7">#1 Science & Technology</td>
      </tr>

      <tr>
      <td style="background-color:#000099">#2 Arts & Entertainment</td>
      </tr>
      
      <tr>
      <td style="background-color:#BFBFBF">#3 Sports</td>
      </tr>

      <tr>
      <td style="background-color:#26A65B">#4 Society</td>
      </tr>
           
      <tr>
      <td style="background-color:#674172">#5 Products & Services</td>
      </tr>

      <tr>
      <td style="background-color:#8E44AD">#6 Transportation</td>
      </tr>

       <tr>
      <td style="background-color:#F89406">#7 Time & Space</td>
      </tr>

       <tr>
      <td style="background-color:#AEA8D3">#8 Special Interests</td>
      </tr>

      <tr>
      <td style="background-color:#F64747">#9 Commons</td>
      </tr>
      </table>
      </div>
  
        
      </div>

 <!--Visualisation container-->     
 <div class="col-md-13">
  <svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink" style="position:absolute">
  <defs>
    <linearGradient id="myLinearGradient1"
                    x1="-50%" y1="0%"
                    x2="-50%" y2="-50%"
                    spreadMethod="reflect">
      <stop offset="0%"   stop-color="#FFFF00" stop-opacity="1"/>
      <stop offset="100%" stop-color="#FF3300" stop-opacity="1"/>
    </linearGradient>
  </defs>

</svg>
          <!-- style="transform: rotateY(130deg);"-->
            <div id='graph1'></div>
 </div>

      </div>
       
            <asp:HiddenField ID="txtJson" runat="server"></asp:HiddenField> 
            <div id="hoverToolTip" class="tooltip">
            Tooltip
            </div>
                     
                     
                     </div>

                     </div>

                  </form>

    </body>
</html>
