namespace MiceHookGUI
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.miceListBox = new System.Windows.Forms.ListBox();
            this.label2 = new System.Windows.Forms.Label();
            this.ticksPerMM = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.MiceRawValue = new System.Windows.Forms.ListBox();
            this.advancerListBox = new System.Windows.Forms.ListBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.advancerDepthMM = new System.Windows.Forms.ListBox();
            this.label7 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(12, 12);
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(208, 20);
            this.textBox1.TabIndex = 0;
            // 
            // miceListBox
            // 
            this.miceListBox.FormattingEnabled = true;
            this.miceListBox.Location = new System.Drawing.Point(13, 58);
            this.miceListBox.Name = "miceListBox";
            this.miceListBox.Size = new System.Drawing.Size(145, 134);
            this.miceListBox.TabIndex = 2;
            this.miceListBox.Tag = "miceListBox";
            this.miceListBox.SelectedIndexChanged += new System.EventHandler(this.miceListBox_SelectedIndexChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(43, 42);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(33, 13);
            this.label2.TabIndex = 4;
            this.label2.Text = "Mice:";
            // 
            // ticksPerMM
            // 
            this.ticksPerMM.Location = new System.Drawing.Point(370, 15);
            this.ticksPerMM.Name = "ticksPerMM";
            this.ticksPerMM.Size = new System.Drawing.Size(107, 20);
            this.ticksPerMM.TabIndex = 5;
            this.ticksPerMM.Tag = "ticksPerMM";
            this.ticksPerMM.TextChanged += new System.EventHandler(this.textBox2_TextChanged);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(391, 40);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(64, 13);
            this.label5.TabIndex = 9;
            this.label5.Text = "Depth (mm):";
            this.label5.Click += new System.EventHandler(this.label5_Click);
            // 
            // timer1
            // 
            this.timer1.Interval = 30;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // MiceRawValue
            // 
            this.MiceRawValue.FormattingEnabled = true;
            this.MiceRawValue.Location = new System.Drawing.Point(164, 58);
            this.MiceRawValue.Name = "MiceRawValue";
            this.MiceRawValue.Size = new System.Drawing.Size(61, 134);
            this.MiceRawValue.TabIndex = 13;
            this.MiceRawValue.Tag = "MiceRawValue";
            // 
            // advancerListBox
            // 
            this.advancerListBox.FormattingEnabled = true;
            this.advancerListBox.Location = new System.Drawing.Point(231, 58);
            this.advancerListBox.Name = "advancerListBox";
            this.advancerListBox.Size = new System.Drawing.Size(145, 134);
            this.advancerListBox.TabIndex = 14;
            this.advancerListBox.Tag = "advancerListBox";
            this.advancerListBox.SelectedIndexChanged += new System.EventHandler(this.advancerListBox_SelectedIndexChanged);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(166, 40);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(62, 13);
            this.label4.TabIndex = 15;
            this.label4.Text = "Raw Value:";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(234, 40);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(114, 13);
            this.label6.TabIndex = 16;
            this.label6.Text = "Assigned to Advancer:";
            // 
            // advancerDepthMM
            // 
            this.advancerDepthMM.FormattingEnabled = true;
            this.advancerDepthMM.Location = new System.Drawing.Point(394, 58);
            this.advancerDepthMM.Name = "advancerDepthMM";
            this.advancerDepthMM.Size = new System.Drawing.Size(78, 134);
            this.advancerDepthMM.TabIndex = 17;
            this.advancerDepthMM.Tag = "advancerDepthMM";
            this.advancerDepthMM.SelectedIndexChanged += new System.EventHandler(this.advancerDepthMM_SelectedIndexChanged);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(291, 15);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(73, 13);
            this.label7.TabIndex = 18;
            this.label7.Text = "Ticks per mm:";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(498, 206);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.advancerDepthMM);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.advancerListBox);
            this.Controls.Add(this.MiceRawValue);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.ticksPerMM);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.miceListBox);
            this.Controls.Add(this.textBox1);
            this.Name = "Form1";
            this.Text = "Mice to Advancers GUI";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox textBox1;
        private System.Windows.Forms.ListBox miceListBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox ticksPerMM;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.ListBox MiceRawValue;
        private System.Windows.Forms.ListBox advancerListBox;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.ListBox advancerDepthMM;
        private System.Windows.Forms.Label label7;
    }
}

