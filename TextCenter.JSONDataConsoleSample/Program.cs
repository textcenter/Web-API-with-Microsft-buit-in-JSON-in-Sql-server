using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace TextCenter.JSONDataConsoleSample
{
    public class Person
    {
        public int Id { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public Dictionary<string, string> DynamicData { get; set; }
        public Person()
        {
            DynamicData = new Dictionary<string, string>();
        }
        public override string ToString()
        {
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.AppendLine($"Id: {Id}");
            stringBuilder.AppendLine($"Firstname: {FirstName}");
            stringBuilder.AppendLine($"LastName: {LastName}");
            stringBuilder.AppendLine($"Dynamic Data:");
            foreach (var kv in DynamicData)
                stringBuilder.AppendLine($"------>{kv.Key}: {kv.Value}");
            return stringBuilder.ToString();
        }
    }

    class Program
    {
        static List<Person> Persons;
        static void Main(string[] args)
        {
            

            Persons = new List<Person>();
            Console.WriteLine("#####  Step1: Create Data ################");
            Console.WriteLine();
            foreach (var p in CreateData())
            {
                Persons.Add(p);
                Console.WriteLine(p.ToString());
            }

            Console.WriteLine("#####  Step2: Send Data to service ################");
            Console.WriteLine();
            var mm = SendDataToService().GetAwaiter().GetResult();
            if (!mm.IsSuccessStatusCode)
                Console.WriteLine($"Failed to submit to the service: {mm.ReasonPhrase}");
            else
            {
                Console.WriteLine("#####  Step3: get Data to service ################");
                Console.WriteLine();
                mm = GetDataFromService().GetAwaiter().GetResult();
                if (!mm.IsSuccessStatusCode)
                    Console.WriteLine($"Failed to get to the service: {mm.ReasonPhrase}");
                else
                    foreach (var p in Persons)
                        Console.WriteLine(p.ToString());
               
            }
            Console.ReadLine();

        }
        static async Task<HttpResponseMessage> SendDataToService()
        {
            HttpClient client = new HttpClient();
            var jsonData = JsonSerializer.Serialize<List<Person>>(Persons);
            var mm = await client.PostAsync("http://localhost:31103/Person", new StringContent(jsonData));
            return mm;
        }
        static async Task<HttpResponseMessage> GetDataFromService()
        {
            HttpClient client = new HttpClient();
            var mm = await client.GetAsync("http://localhost:31103/Person");
            if(mm.IsSuccessStatusCode)
            {
                var jsonData = await  mm.Content.ReadAsStringAsync();
                Persons = JsonSerializer.Deserialize<List<Person>>(jsonData);
            }
            return mm;
        }
        static IEnumerable<Person> CreateData()
        {
            Person p = new Person()
            {
                FirstName = "Person",
                LastName = "one"

            };
            p.DynamicData.Add("US Citizen", "Yes");
            p.DynamicData.Add("Mary", "Yes");
            p.DynamicData.Add("Gender", "Female");
            yield return p;

            p = new Person()
            {
                FirstName = "Person",
                LastName = "Two"

            };
            p.DynamicData.Add("US Citizen", "No");
            p.DynamicData.Add("Gender", "Male");
            yield return p;

            p = new Person()
            {
                FirstName = "Person",
                LastName = "Three"

            };
            p.DynamicData.Add("US Citizen", "No");
            p.DynamicData.Add("Musican", "Yes");
            yield return p;

        }
    }
}
