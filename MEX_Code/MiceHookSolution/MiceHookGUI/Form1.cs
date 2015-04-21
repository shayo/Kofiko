using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using ZeroMQ;
using System.Threading;
using System.IO;
 
namespace MiceHookGUI
{
    public partial class Form1 : Form
    {
 
        [DllImport("MiceHookDLL.dll", EntryPoint = "API_Init")]
        static extern void API_Init();

        [DllImport("MiceHookDLL.dll", EntryPoint = "API_Release")]
        static extern void API_Release();

        [DllImport("MiceHookDLL.dll", EntryPoint = "API_GetNumMice")]
        static extern Int32 API_GetNumMice();


        [DllImport("MiceHookDLL.dll",  CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi,  EntryPoint = "API_GetMouseName")]
        static extern int API_GetMouseName(int mouseIndex, StringBuilder lpBuffer);

        [DllImport("MiceHookDLL.dll",   EntryPoint = "API_GetMouseWheel")]
        static extern ulong API_GetMouseWheel(int mouseIndex);

        public int numMice = 0;
        public Queue<String> messagesToThread = new Queue<String>();
        public Queue<String> messagesFromThread = new Queue<String>();
        public int[] advancerIDs;
        public String[] advancerNames;
        public Double[] advancerDepth;
        public int[] miceTickPosition;
        public int[] micePrevTickPosition;
        public int[] mouseIndexToAdvancerIndex;

        public Form1()
        {

            InitializeComponent();
        }

        private void Form1_FormClosing(Object sender, FormClosingEventArgs e)
        {
            API_Release();
        }

        public String Drop(String[] strings, int index)
        {
            String S = "";
            for (int k = index; k < strings.Length; k++)
            {
                if (k == strings.Length - 1)
                    S += strings[k];
                else
                    S += strings[k] + " ";
            }
            return S;
        }

        private void ClientThread()
        {
            Thread.Sleep(10);

            ZmqContext context = ZmqContext.Create();

            ZmqSocket socket = context.CreateSocket(SocketType.REQ);
            socket.Connect("tcp://localhost:5556");

            while (true)
            {
                if (messagesToThread.Count > 0)
                {
                    String message = messagesToThread.Dequeue();
                    String[] splitMessage = message.Split(' ');
                    if (splitMessage[0] == "SetAdvancerDepth")
                    {
                        socket.Send("ProcessorCommunication Advancers "+message, Encoding.UTF8);
                        String response = socket.Receive(Encoding.UTF8);
                        String[] inputs = response.Split(' ');
                        if (inputs[0] == "NewAdvancerDepth")
                        {
                            // update the internal structure about the new depth
                            double newDepth = Convert.ToDouble(inputs[2]);
                            int advancerID = Convert.ToInt32(inputs[1]);
                            for (int k = 0; k < advancerNames.Length; k++)
                            {
                                if (advancerIDs[k] == advancerID)
                                    advancerDepth[k] = newDepth;
                            }

                            messagesFromThread.Enqueue("AdvancerQueryFinished");
                        }
                    }

                    if (splitMessage[0] == "QueryAdvancers")
                    {
                        socket.Send("ProcessorCommunication Advancers GetNumAdvancers", Encoding.UTF8);
                        
                        String FullCommand = socket.Receive(Encoding.UTF8);
                        String[] inputs = FullCommand.Split(' ');
                        if (inputs[0] == "NumAdvancers")
                        {
                            int numAdvancers = Convert.ToInt16(inputs[1]);
                            // now query advancer names
                            advancerNames = new String[numAdvancers];
                            advancerDepth = new Double[numAdvancers];
                            advancerIDs = new int[numAdvancers];
                            for (int k = 0; k < numAdvancers; k++)
                            {
                                socket.Send("ProcessorCommunication Advancers GetAdvancerIdName " + k.ToString(), Encoding.UTF8);
                                String response = socket.Receive(Encoding.UTF8);
                                String[] splitResponse = response.Split(' ');
                                if (splitResponse[0] == "AdvancerIdName")
                                {
                                    advancerIDs[k] = Convert.ToInt32(splitResponse[1]);
                                    advancerNames[k] = Drop(splitResponse, 2);
                                    socket.Send("ProcessorCommunication Advancers GetAdvancerDepth " + advancerIDs[k].ToString(), Encoding.UTF8);
                                    String response2 = socket.Receive(Encoding.UTF8);

                                    String[] splitResponse2 = response2.Split(' ');
                                    if (splitResponse2[0] == "AdvancerDepth")
                                    {
                                        advancerDepth[k] = Convert.ToDouble(splitResponse2[1]);
                                    }
                                    else
                                    {
                                        advancerDepth[k] = 0.0;
                                    }






                                }
                                else
                                {
                                    advancerNames[k] = "Error";
                                }

                               


                            }

                            messagesFromThread.Enqueue("AdvancerQueryFinished");
                        }
                    }
                }
                
               
                
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            advancerListBox.Items.Clear();
             var client = new Thread(ClientThread);
             ticksPerMM.Text = "114";
            client.Start();
       
             API_Init();

             RefreshScreen();
             timer1.Start();
        }

        public void RefreshScreen()
        {
            // query number of mice on this computer
            numMice = API_GetNumMice();
            StringBuilder sbBuffer = new StringBuilder(1000);
            String[] names = new String[numMice];
            miceListBox.Items.Clear();
            miceTickPosition = new int[numMice];
            micePrevTickPosition = new int[numMice];
            mouseIndexToAdvancerIndex = new int[numMice];
            // query mice wheels
            MiceRawValue.Items.Clear();
            for (int k = 0; k < numMice; k++)
            {
                mouseIndexToAdvancerIndex[k] = -1;
                micePrevTickPosition[k] = 0;
                MiceRawValue.Items.Add(micePrevTickPosition[0]);

                API_GetMouseName(k, sbBuffer);
                names[k] = sbBuffer.ToString();
                miceListBox.Items.Add(names[k]);
                //long wheel = API_GetMouseWheel(k);
            }

            messagesToThread.Enqueue("QueryAdvancers");

        }

        private void RefreshButton_Click(object sender, EventArgs e)
        {
          
       
        }

        private void miceListBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            int selectedMouse = miceListBox.SelectedIndex;

            int matched_advancer = mouseIndexToAdvancerIndex[selectedMouse];
            if (matched_advancer >= 0)
                advancerListBox.SetSelected(matched_advancer, true);
            else
                advancerListBox.SelectedItems.Clear();

        }

      
        private void timer1_Tick(object sender, EventArgs e)
        {
            for (int k = 0; k < numMice; k++)
            {
                ulong wheel = API_GetMouseWheel(k);
                float actualTicks;
                if (wheel > ulong.MaxValue / 2)
                {
                    actualTicks = ((ulong.MaxValue-wheel) / 4294967297);
                    actualTicks *= -1;
                }
                else
                {
                    actualTicks = (wheel / 4294967297);
                }
                miceTickPosition[k] = Convert.ToInt32(actualTicks);
            }

            
            for (int k = 0; k < numMice; k++)
            {
                if (miceTickPosition[k] != micePrevTickPosition[k])
                {
                    double TicksPerMM = Convert.ToDouble(ticksPerMM.Text);
                    int DeltaTick = miceTickPosition[k]-micePrevTickPosition[k];
                    double DeltaMM = Convert.ToDouble(DeltaTick)/TicksPerMM;
                    micePrevTickPosition[k] = miceTickPosition[k];
                    MiceRawValue.Items[k] = miceTickPosition[k].ToString();
                    // inform GUI about the change!
                    if (mouseIndexToAdvancerIndex[k] >= 0)
                        messagesToThread.Enqueue("SetAdvancerDepth " + advancerIDs[mouseIndexToAdvancerIndex[k]].ToString() + " " + DeltaMM.ToString());
                }
            }


            if (messagesFromThread.Count > 0)
            {
                String msg = messagesFromThread.Dequeue();
                if (msg == "AdvancerQueryFinished")
                {
                    advancerListBox.Items.Clear();
                    advancerDepthMM.Items.Clear();
                    for (int k = 0; k < advancerNames.Length; k++)
                    {
                        advancerListBox.Items.Add(advancerNames[k]);
                        advancerDepthMM.Items.Add(advancerDepth[k].ToString());
                    }


                }
            }

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void advancerListBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            int selectedMouse = miceListBox.SelectedIndex;
            if (selectedMouse >= 0)
                mouseIndexToAdvancerIndex[selectedMouse] = advancerListBox.SelectedIndex;

        }

        private void advancerDepthMM_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

    }
}
