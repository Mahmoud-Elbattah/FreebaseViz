<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="SchemaVisualiser.WebForm1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function Show() {
            ///alert(document.getElementById('txt1').value);
            alert('go');
            var txt = PageMethods.greetUser(1);
            alert(txt);

        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:scriptmanager runat="server"  EnablePageMethods="true">
    </asp:scriptmanager>
    <div>
    </div>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="txt1" runat="server"></asp:HiddenField>
                        <asp:button runat="server" text="Button" ID="btn1" 
    onclick="btn1_Click"/>
        </ContentTemplate>
    </asp:UpdatePanel>
    <input id="Button1" type="button" value="html Show" onclick="Show();" />
    </form>
</body>
</html>
