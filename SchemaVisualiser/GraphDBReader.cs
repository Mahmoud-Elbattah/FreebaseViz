using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Neo4jClient;
using Newtonsoft.Json;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.Collections;
namespace FreebaseViz
{
    public class FreebaseType
    {
        public int ID;
        public string Name;
        public long InstanceCount;
        public string ParentDomain;
        public int categoryID;//One of the 9 categories of Freebase
    }
    public class GraphDBReader
    {
        private static GraphClient neo4jClient;
        private static int NodesCount;
        private static int LinksCount;
        public static FreebaseType[] types;
        private static string nodesFilter;
        private static string relationshipsFilter;

        #region Connecting to Neo4j  Functions
        public static void InitNeo4JConnection(string hostURL)
        {
            hostURL = hostURL.Replace("http://", "");

            neo4jClient = new GraphClient(new Uri("http://" + hostURL));
            neo4jClient.Connect();

            Console.WriteLine("Connection to Neo4J succeeded.");

        }
        public static void InitNeo4JConnection(string hostURL, string userid, string password)
        {
            hostURL = hostURL.Replace("http://", "");
            neo4jClient = new GraphClient(new Uri("http://" + userid + ":" + password + "@" + hostURL));
            neo4jClient.Connect();
        }
       
        #endregion
        #region Main Functions for Building the Schema Graph
        public static string RetrieveNodes(string categoryFilter="")
        {
            //Selecting all nodes of label "Type"
            if (categoryFilter == "")
            {
                nodesFilter = "typeNode.categoryID IS NOT NULL";
                relationshipsFilter = "childNode.categoryID IS NOT NULL";
            }
            else
            {
                nodesFilter = categoryFilter.Replace(",", " or typeNode.categoryID=");
                nodesFilter = "typeNode.categoryID=" + nodesFilter;
                //Setting relationships filter
                string[] ids = categoryFilter.Split(',');
                string condition1 = "(";
                string condition2 = "(";
                for (int i = 0; i < ids.Length; i++)
                {
                    condition1 += "childNode.categoryID=" + ids[i];
                    condition2 += "parentNode.categoryID=" + ids[i];
                    if ((i + 1) < ids.Length)
                    {
                        condition1 += " or ";
                        condition2 += " or ";
                    }
                }
                condition1 += ")";
                condition2 += ")";
                relationshipsFilter = condition1 + " And " + condition2;
            }
            var   rawNodes= neo4jClient.Cypher
                    .Match("(typeNode:Type)")
                    .Where(nodesFilter)
                    .Return(typeNode => typeNode.As<Node<string>>())
                     .Results;

   
            //Deserializing query results
            var output = rawNodes.Select(node => JsonConvert.DeserializeObject<dynamic>(node.Data)).ToList();
            //Converting into array of nodes

            object[] nodes = (object[])output.ToArray();
            //Converting array of nodes into array of FreebaseType, which can be used to search for nodes via LINQ
            types = Array.ConvertAll<object, FreebaseType>(nodes, ConvertObjectToFreebaseType);
            NodesCount = nodes.Length;
            //Convert nodes json array into array of strings
            string[] jsonElements = nodes.Where(x => x != null)
                                   .Select(x => x.ToString())
                                   .ToArray();
            //Convert array of json nodes into a single json string 
            string jsonString = ConvertStringArrayToString(jsonElements);

            jsonString = jsonString.Replace("categoryID", "groupId");
            jsonString = Regex.Replace(jsonString, @"\t|\n|\r", "");
            jsonString = jsonString.TrimEnd(',');
            return jsonString;  
        }
        public static string RetrieveRelationships()
        {
            var rawNodes = neo4jClient.Cypher
                              .Match("(childNode:Type)-[:Included_In]->(parentNode:Type)")
                               //.Where("(childNode.categoryID = 1 or childNode.categoryID = 9) And (parentNode.categoryID = 1 or parentNode.categoryID = 9)")
                              .Where(relationshipsFilter)
                               .Return((childNode, parentNode) => new
                              {
                                  source = childNode.As<Node<string>>(),
                                  target = parentNode.As<Node<string>>()
                              })
                             .Results;
            //Deserializing source nodes
            var output = rawNodes.Select(node => JsonConvert.DeserializeObject<dynamic>(node.source.Data)).ToList();
            object[] sourceNodes = (object[])output.ToArray();
            string[] jsonElementsSrc = sourceNodes.Where(x => x != null)
                         .Select(x => x.ToString())
                         .ToArray();
            output = rawNodes.Select(node => JsonConvert.DeserializeObject<dynamic>(node.target.Data)).ToList();
            object[] targetNodes = (object[])output.ToArray();
            string[] jsonElementsTarget = targetNodes.Where(x => x != null)
                         .Select(x => x.ToString())
                         .ToArray();

            LinksCount = jsonElementsSrc.Length;
            string[] links = new string[jsonElementsSrc.Length];

            for (int i = 0; i < links.Length; i++)
            {
                string srcID = GetFirstInstance<string>("ID", jsonElementsSrc[i]);
                string targetID = GetFirstInstance<string>("ID", jsonElementsTarget[i]);
                links[i] = "{\"source\":" + GetIndex(srcID) + ",\"target\":" + GetIndex(targetID) + ",\"value\":1}";
            }
            string jsonString = ConvertStringArrayToString(links);
            jsonString = Regex.Replace(jsonString, @"\t|\n|\r", "");
            jsonString = jsonString.TrimEnd(',');
            // System.IO.File.WriteAllText(@"F:\links.txt", jsonString);
            return jsonString;
        }
        #endregion
        #region Finding a Specific Node and its related nodes
        public static string FindNode(string nodeName)
        {

            //Selecting all nodes of label "Type"
            var rawNodes = neo4jClient.Cypher
                         .Match("(childNode:Type)<-[:Included_In]->(parentNode:Type)")
                         .Where("childNode.Name='" + nodeName + "'")
                           .ReturnDistinct((childNode, parentNode) => new
                           {
                               source = childNode.As<Node<string>>(),
                               target = parentNode.As<Node<string>>()
                           })
                          .Results;


            int count = rawNodes.Count();
            //Deserializing query results
            var output = rawNodes.Select(node => JsonConvert.DeserializeObject<dynamic>(node.source.Data)).Skip(count - 1).ToList();

            output = output.Union(rawNodes.Select(node => JsonConvert.DeserializeObject<dynamic>(node.target.Data)).ToList()).ToList();

            //Converting into array of nodes
            object[] nodes = (object[])output.ToArray();
            //Converting array of nodes into array of FreebaseType, which can be used to search for nodes via LINQ
            types = Array.ConvertAll<object, FreebaseType>(nodes, ConvertObjectToFreebaseType);

            NodesCount = nodes.Length;
            //Convert nodes json array into array of strings
            string[] jsonElements = nodes.Where(x => x != null)
                                   .Select(x => x.ToString())
                                   .ToArray();
            //Convert array of json nodes into a single json string 
            string jsonString = ConvertStringArrayToString(jsonElements);

            jsonString = jsonString.Replace("categoryID", "groupId");
            jsonString = Regex.Replace(jsonString, @"\t|\n|\r", "");
            jsonString = jsonString.TrimEnd(',');

            return jsonString;

        }

        public static string RetrieveRelationships(string nodeName)
        {
            var rawNodes = neo4jClient.Cypher
                              .Match("(childNode:Type)<-[:Included_In]->(parentNode:Type)")
                             .Where("childNode.Name='" + nodeName + "'")
                           .Return((childNode, parentNode) => new
                           {
                               source = childNode.As<Node<string>>(),
                               target = parentNode.As<Node<string>>()
                           })
                             .Results;
            //Deserializing source nodes
            var output = rawNodes.Select(node => JsonConvert.DeserializeObject<dynamic>(node.source.Data)).ToList();
            object[] sourceNodes = (object[])output.ToArray();
            string[] jsonElementsSrc = sourceNodes.Where(x => x != null)
                         .Select(x => x.ToString())
                         .ToArray();
            output = rawNodes.Select(node => JsonConvert.DeserializeObject<dynamic>(node.target.Data)).ToList();
            object[] targetNodes = (object[])output.ToArray();
            string[] jsonElementsTarget = targetNodes.Where(x => x != null)
                         .Select(x => x.ToString())
                         .ToArray();

            LinksCount = jsonElementsSrc.Length;
            string[] links = new string[jsonElementsSrc.Length];

            for (int i = 0; i < links.Length; i++)
            {
                string srcID = GetFirstInstance<string>("ID", jsonElementsSrc[i]);
                string targetID = GetFirstInstance<string>("ID", jsonElementsTarget[i]);
                links[i] = "{\"source\":" + GetIndex(srcID) + ",\"target\":" + GetIndex(targetID) + ",\"value\":1}";
            }
            string jsonString = ConvertStringArrayToString(links);
            jsonString = Regex.Replace(jsonString, @"\t|\n|\r", "");
            jsonString = jsonString.TrimEnd(',');
            return jsonString;
        }

        #endregion
        #region General-Use Functions
        private static string ConvertStringArrayToString(string[] array)
        {
            //
            // Concatenate all the elements into a StringBuilder.
            //
            StringBuilder builder = new StringBuilder();
            foreach (string value in array)
            {
                builder.Append(value);
                builder.Append(',');
            }
            return builder.ToString();
        }
        private static T GetFirstInstance<T>(string propertyName, string json)
        {
            using (var stringReader = new StringReader(json))
            using (var jsonReader = new JsonTextReader(stringReader))
            {
                while (jsonReader.Read())
                {
                    if (jsonReader.TokenType == JsonToken.PropertyName
                        && (string)jsonReader.Value == propertyName)
                    {
                        jsonReader.Read();

                        var serializer = new JsonSerializer();
                        return serializer.Deserialize<T>(jsonReader);
                    }
                }
                return default(T);
            }
        }
        public static int GetNodesCount()
        {
            return NodesCount;
        }
        public static int GetLinksCount()
        {
            return LinksCount;
        }

        //GetIndex return the index of the node in the array of nodes
        //The indices of nodes are essential for creating links, as VivaGraphJs identifies links by node indices 
        private static string GetIndex(string id)
        {
            int index = Array.FindIndex(types, x => x.ID.ToString() == id);
            return index.ToString();
            //var foundItem = freebaseTypes.SingleOrDefault(FreebaseType => FreebaseType.ID == int.Parse(id));
            // return (foundItem.index).ToString();
        }
        //Custom method that converts a node of type 'object' into 'FreebaseType'
        static FreebaseType ConvertObjectToFreebaseType(object node)
        {
            //To deserialise a single json-valued node into FreebaseType objec
            FreebaseType type = JsonConvert.DeserializeObject<FreebaseType>(node.ToString());
            return type;
        }
        #endregion

    }
}