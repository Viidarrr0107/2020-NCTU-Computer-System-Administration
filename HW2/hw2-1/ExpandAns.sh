#!/bin/sh

# $ top -n max -o res | awk 'NR>9' | awk '<CodeWithoutComment>'
# $ top -n max -o res | ./ans.sh
# You can test by
# $ cat top.log | awk 'NR>9' | awk ''
# if Shebang error, use vim and type
# :set fileformat=unix
# 
BEGIN 
{
	tr=0;
	tw=0;
	for(i=0;i<6;i++){
		table_w[i,0] = "none";
		table_w[i,1] = "none";
		table_w[i,2] = "none";
		table_w[i,3] = "0.00";
	}
} 
{ 
	if(tr<5){
		table_r[tr, 0] = $1;
		table_r[tr, 1] = $12;
		table_r[tr, 2] = $2;
		table_r[tr, 3] = $7;
		tr++;
	}
	cpu_v=substr($11, 1, length($11)-1);
	if(cpu_v>=0.5){
		table_w[5, 0] = $1;
		table_w[5, 1] = $12;
		table_w[5, 2] = $2;
		table_w[5, 3] = cpu_v;
		for(i=5;i>0;i--){
			if((table_w[i,3]+0)>(table_w[i-1,3]+0)){
				for(j=0;j<4;j++){
					tmp=table_w[i-1,j];
					table_w[i-1,j]=table_w[i,j];
					table_w[i,j]=tmp;
				}
			}
		}
		if(tw<5){tw++;}
	}
} 
END 
{
	printf("Top Five Processes of WCPU over 0.5\n\nPID\tcommand\tuser\tWCPU\n");
	for(i=0;i<tw;i++){printf("%s\t%s\t%s\t%s%%\n", table_w[i,0], table_w[i,1], table_w[i,2], table_w[i,3]); table_u[table_w[i,2]]++;}
	printf("\nTop Five Processes of RES\n\nPID\tcommand\tuser\tRES\n");
	for(i=0;i<tr;i++){printf("%s\t%s\t%s\t%s\n", table_r[i,0], table_r[i,1], table_r[i,2], table_r[i,3]); table_u[table_r[i,2]]++;}
	printf("\nBad Users:\n\n");
	for(key in table_u){
		if(key=="root")
			print "\033[32m" key "\033[0m";
		else if(table_u[key]>=2)
			print "\033[31m" key "\033[0m";
		else
			print "\033[33m" key "\033[0m";
	}
}
