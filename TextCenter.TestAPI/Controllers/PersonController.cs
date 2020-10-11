using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using TextCenter.CoreAPI.BAL;

namespace TextCenter.TestAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PersonController : ControllerBase
    {
        [HttpGet]
        public string Get()
        {
            var rs = PersonManager.GetJsonPersons();
            return rs.Value;
        }
        [HttpPost]
        public async Task Post()
        {
            var jsonData = await ReadBodyContent(Request);
            PersonManager.InsertUpdatePersons(jsonData);
          
        }
        private async Task<string> ReadBodyContent(HttpRequest request)
        {
            using (StreamReader stream = new StreamReader(Request.Body))
            {
                string body = await stream.ReadToEndAsync();
                return body;
            }
        }
    }
}
