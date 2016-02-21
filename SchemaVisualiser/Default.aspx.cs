using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreebaseViz
{
    public partial class Visualization : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                try
                {
                    //Initialising Neo4j connection
                    GraphDBReader.InitNeo4JConnection("DB_URL", "Username", "Password");
                    //Retrieving graph nodes
                    string nodes = GraphDBReader.RetrieveNodes();
                    //Retrieving graph links
                    string links = GraphDBReader.RetrieveRelationships();
                    //txtJson will contain the full JSON string to be read the VivaGraph JS library
                    txtJson.Value = "{" + "\"nodes\":[" + nodes + "]," + "\"links\":[" + links + "]" + "}";
                    //Displaying graph summary
                    lblNodesCount.Text = GraphDBReader.GetNodesCount().ToString();
                    lblLinksCount.Text = GraphDBReader.GetLinksCount().ToString();
                    //Filling the dropdown used for search and filtering purposes
                    FillDropdown();
                }
                catch
                {
                    //In case that the connection to the Neo4j database fails
                    ScriptManager.RegisterStartupScript(this, typeof(Page), "UpdateMsg", "alert('Connection to Neo4j database failed.\\n Please check database connection settings.');", true);
                }
            }
        }
        #region Interactivity Features
        //Filtering by Freebase categories checkboxes
        protected void chkb_CheckedChanged(object sender, EventArgs e)
        {

            string selectedCategories = GetSelectedCats();
            string nodes = GraphDBReader.RetrieveNodes(selectedCategories);
            string links = GraphDBReader.RetrieveRelationships();
            txtJson.Value = "{" + "\"nodes\":[" + nodes + "]," + "\"links\":[" + links + "]" + "}";
            lblNodesCount.Text = GraphDBReader.GetNodesCount().ToString();
            lblLinksCount.Text = GraphDBReader.GetLinksCount().ToString();
            ScriptManager.RegisterStartupScript(this, typeof(Page), "UpdateMsg", "clearGraph();onLoad();", true);

        }

        //Filtering by selecting a particular Freebase Type from the dropdown list
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string nodes = GraphDBReader.FindNode(dropdownTypes.SelectedValue);
            string links = GraphDBReader.RetrieveRelationships(dropdownTypes.SelectedValue);
            txtJson.Value = "{" + "\"nodes\":[" + nodes + "]," + "\"links\":[" + links + "]" + "}";
            lblNodesCount.Text = GraphDBReader.GetNodesCount().ToString();
            lblLinksCount.Text = GraphDBReader.GetLinksCount().ToString();
            ScriptManager.RegisterStartupScript(this, typeof(Page), "UpdateMsg", "clearGraph();onLoad();", true);
        }
        protected void FillDropdown()
        {
            FreebaseType[] sortedTypes = GraphDBReader.types.OrderBy(i => i.Name).ToArray();
            for (int i = 0; i < sortedTypes.Length; i++)
                dropdownTypes.Items.Add(sortedTypes.ElementAt(i).Name);
        }
        protected string GetSelectedCats()
        {
            string selectedCats = "";
            if (chkbCat1.Checked == true)
                selectedCats += ",1";
            if (chkbCat2.Checked == true)
                selectedCats += ",2";
            if (chkbCat3.Checked == true)
                selectedCats += ",3";
            if (chkbCat4.Checked == true)
                selectedCats += ",4";
            if (chkbCat5.Checked == true)
                selectedCats += ",5";
            if (chkbCat6.Checked == true)
                selectedCats += ",6";
            if (chkbCat7.Checked == true)
                selectedCats += ",7";
            if (chkbCat8.Checked == true)
                selectedCats += ",8";
            if (chkbCat9.Checked == true)
                selectedCats += ",9";
            selectedCats = selectedCats.TrimStart(',');
            return selectedCats;
        }
        protected void dropdownTypes_SelectedIndexChanged(object sender, EventArgs e)
        {
            btnSearch_Click(null, null);
        }

        #endregion

    }
}