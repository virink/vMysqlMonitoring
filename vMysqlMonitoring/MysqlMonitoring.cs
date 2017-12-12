using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using MySql.Data.MySqlClient;

namespace MysqlMonitoringMain
{
    public partial class MysqlMonitoring : Form
    {
        string config_path = System.Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments)+Path.DirectorySeparatorChar+"vmysqlmotitoring.conf";
        //断点时间
        string var_datatime = "";

        // 数据库配置
        string M_str_sqlcon = "";

        BindingSource Bs = null;

        public MysqlMonitoring()
        {
            InitializeComponent();
        }

        [DllImport("kernel32")]
        private static extern int GetPrivateProfileString(string section, string key, string defVal, StringBuilder retVal, int size, string filePath);

        [DllImport("kernel32")]
        private static extern long WritePrivateProfileString(string section, string key, string val, string filePath);

        #region  建立MySql数据库连接
        /// <summary>    
        /// 建立数据库连接.    
        /// </summary>    
        /// <returns>返回MySqlConnection对象</returns>
        public MySqlConnection func_getmysqlcon()
        {
            MySqlConnection myCon = new MySqlConnection(M_str_sqlcon);
            return myCon;
        }
        #endregion

        #region  执行MySqlCommand命令
        /// <summary>    
        /// 执行MySqlCommand    
        /// </summary>    
        /// <param name="M_str_sqlstr">SQL语句</param>    
        public int func_getmysqlcom(string M_str_sqlstr)
        {
            int count = 0;
            MySqlConnection mysqlcon = this.func_getmysqlcon();
            mysqlcon.Open();
            MySqlCommand mysqlcom = new MySqlCommand(M_str_sqlstr, mysqlcon);
            count = mysqlcom.ExecuteNonQuery();
            mysqlcom.Dispose();
            mysqlcon.Close();
            mysqlcon.Dispose();
            return count;
        }
        #endregion

        #region  创建MySqlDataReader对象
        /// <summary>   
        /// 创建一个MySqlDataReader对象    
        /// </summary>    
        /// <param name="M_str_sqlstr">SQL语句</param>    
        /// <returns>返回MySqlDataReader对象</returns>    
        public DataSet func_getmysqlread(string M_str_sqlstr)
        {
            MySqlConnection mysqlcon = this.func_getmysqlcon();
            mysqlcon.Open();
            MySqlDataAdapter sda = new MySqlDataAdapter(M_str_sqlstr, mysqlcon);
            DataSet ds = new DataSet();
            sda.Fill(ds);
            return ds;
        }
        #endregion

        #region  读取INI文件
        /// <summary>    
        /// 读取INI文件    
        /// </summary>    
        /// <param name="section">项目名称(如 [section] )</param>    
        /// <param name="skey">键</param>   
        /// <param name="path">路径</param> 
        public string IniReadValue(string section, string skey, string path, string _default = "")
        {
            StringBuilder temp = new StringBuilder(500);
            int i = GetPrivateProfileString(section, skey, _default, temp, 500, path);
            return temp.ToString();
        }
        #endregion

        #region  写入INI文件
        /// <summary>
        /// 写入ini文件
        /// </summary>
        /// <param name="section">项目名称</param>
        /// <param name="key">键</param>
        /// <param name="value">值</param>
        /// <param name="path">路径</param>
        public void IniWrite(string section, string key, string value, string path)
        {
            WritePrivateProfileString(section, key, value, path);
        }
        #endregion

        private void F_MysqlMonitoring_Load(object sender, EventArgs e)
        {
            db_config_str();
            init_general_log();
        }

        private void init_general_log()
        {
            try
            {
                func_getmysqlcom("set global general_log=off;truncate table general_log;set global general_log=on;SET GLOBAL log_output='table';");
            }
            catch (Exception ee)
            {
                MessageBox.Show(ee.Message, "提示");
            }
        }

        private void setTimeNow()
        {
            var_datatime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            txt_break.Text = "断点：" + var_datatime;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            setTimeNow();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            try
            {
                string sql = "SELECT event_time,argument FROM mysql.general_log WHERE (command_type = 'Query' OR command_type = 'Execute') AND argument NOT LIKE '%general_log%' AND argument NOT LIKE '%select event_time,argument from%' AND argument NOT LIKE '%SHOW%' AND argument NOT LIKE '%SELECT STATE%' AND argument NOT LIKE '%SET NAMES%' AND argument NOT LIKE '%SET PROFILING%' AND argument NOT LIKE '%SELECT QUERY_ID%' AND event_time>'" + var_datatime + "'";
                DataSet ds = func_getmysqlread(sql);
                DataTableCollection tables = ds.Tables;
                DataView view1 = new DataView(tables[0]);
                Bs = new BindingSource();
                Bs.DataSource = view1;
                dataGridView1.DataSource = Bs;
                dataGridView1.AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.DisplayedCellsExceptHeaders;
                txt_count.Text = "行数：" + Bs.Count;
                dataGridView1.Columns[0].HeaderText = "时间";
                dataGridView1.Columns[1].HeaderText = "语句";
                dataGridView1.Columns[0].Width = 150;
                dataGridView1.Columns[1].AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;
                if (this.dataGridView1.Rows.Count > 0)
                {
                    dataGridView1.FirstDisplayedScrollingRowIndex = this.dataGridView1.Rows.Count - 1;
                }

            }
            catch (Exception ee)
            {
                MessageBox.Show(ee.Message, "提示");
            }
        }

        private void CopyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count > 0)
            {
                Clipboard.SetDataObject(dataGridView1.SelectedRows[0].Cells[1].Value.ToString());
            }
        }

        private void txt_searchkey_TextChanged(object sender, EventArgs e)
        {
            if (Bs != null)
            {
                Bs.RemoveFilter();
                if (txt_searchkey.Text != "")
                {
                    Bs.Filter = "argument like '%" + txt_searchkey.Text.Replace("'", "\\'") + "%'";
                    txt_count.Text = "行数：" + Bs.Count;
                }
                else
                {
                    txt_count.Text = "行数：" + Bs.Count;
                }
            }
        }

        private void db_config_str()
        {
            txt_host.Text = IniReadValue("Config", "host", config_path, "localhost");
            txt_port.Text = IniReadValue("Config", "port", config_path, "3306");
            txt_user.Text = IniReadValue("Config", "user", config_path, "root");
            txt_pass.Text = IniReadValue("Config", "pass", config_path, "123456");
            M_str_sqlcon = "server=" + txt_host.Text + ";port=" + txt_port.Text + ";user id=" + txt_user.Text + ";password=" + txt_pass.Text + ";database=mysql";
        }

        private void txt_host_TextChanged(object sender, EventArgs e)
        {
            IniWrite("Config", "host", txt_host.Text, config_path);
            M_str_sqlcon = "server=" + txt_host.Text + ";port=" + txt_port.Text + ";user id=" + txt_user.Text + ";password=" + txt_pass.Text + ";database=mysql";
        }

        private void txt_port_TextChanged(object sender, EventArgs e)
        {
            IniWrite("Config", "port", txt_port.Text, config_path);
            M_str_sqlcon = "server=" + txt_host.Text + ";port=" + txt_port.Text + ";user id=" + txt_user.Text + ";password=" + txt_pass.Text + ";database=mysql";
        }

        private void txt_user_TextChanged(object sender, EventArgs e)
        {
            IniWrite("Config", "user", txt_user.Text, config_path);
            M_str_sqlcon = "server=" + txt_host.Text + ";port=" + txt_port.Text + ";user id=" + txt_user.Text + ";password=" + txt_pass.Text + ";database=mysql";
        }

        private void txt_pass_TextChanged(object sender, EventArgs e)
        {
            IniWrite("Config", "pass", txt_pass.Text, config_path);
            M_str_sqlcon = "server=" + txt_host.Text + ";port=" + txt_port.Text + ";user id=" + txt_user.Text + ";password=" + txt_pass.Text + ";database=mysql";
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("https://www.virzz.com");
        }

        private void linkLabel2_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("https://github.com/virink/vMysqlMonitoring");
        }

    }
}
