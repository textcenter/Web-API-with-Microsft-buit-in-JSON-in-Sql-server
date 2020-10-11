using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace TextCenter.CoreAPI.BAL
{
    public class PersonManager
    {

        public static KeyValuePair<bool, string> GetJsonPersons()
        {
            try
            {
                using (SqlConnection cnn = new SqlConnection(AppSettingInfo.ConnectionString))
                {
                    cnn.Open();
                    SqlCommand cmd = new SqlCommand("GetPersons", cnn)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    var rs = cmd.ExecuteScalar();
                    return new KeyValuePair<bool, string>(true, rs?.ToString());


                }
            }
            catch (Exception ex)
            {
                return new KeyValuePair<bool, string>(false, ex.Message);
            }

        }
        public static KeyValuePair<bool, string> InsertUpdatePersons(string jsonData)
        {
            try
            {
                SendJsonDataToStoreProcedure("InsertUpdatePersons", jsonData);
                return new KeyValuePair<bool, string>(true, "");
            }
            catch (Exception ex)
            {
                return new KeyValuePair<bool, string>(false, ex.Message);
            }

        }
        private static void SendJsonDataToStoreProcedure(string procName, string jsonData, string parameterame = "JsonData")
        {
            using (SqlConnection cnn = new SqlConnection(AppSettingInfo.ConnectionString))
            {
                cnn.Open();
                SqlCommand cmd = new SqlCommand(procName, cnn)
                {
                    CommandType = System.Data.CommandType.StoredProcedure

                };
                SqlParameter p = new SqlParameter()
                {
                    ParameterName = parameterame,
                    Value = jsonData,
                    SqlDbType = System.Data.SqlDbType.NText
                };
                cmd.Parameters.Add(p);
                var rs = cmd.ExecuteNonQuery();

            }
        }
    }
}
