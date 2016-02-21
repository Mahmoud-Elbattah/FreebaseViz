<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm2.aspx.cs" Inherits="SchemaVisualiser.WebForm2" %>

<!DOCTYPE html>
<html>
<head>
  <title>Calling page methods with jQuery</title>
  <style type="text/css">
    #Result {
      cursor: pointer;
    }
  </style>
</head>
<body>
  <div id="Result">Click here for the time.</div>
  <input value="test" type="button" onclick="call();" />
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
  <script>
  function call()
   {
   var x = "{'id':2}";
          $.ajax({
              type: "POST",
              url: "WebForm2.aspx/HelloWorld",
              data: x,
              contentType: "application/json",
              dataType: "json",
              success: function (msg) {
                  // Replace the div's content with the page method's return.
                  $("#Result").text(msg.d);
              }
          });
  }
 



  </script>
</body>
</html>
