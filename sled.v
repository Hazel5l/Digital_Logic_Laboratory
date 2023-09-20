module sled(dig,clk,seg,key,led);
input clk;
input [6:1] key;
output reg [1:8] led;
output reg [7:0] seg;
output reg [7:0] dig;
reg [25:0] counter1;
reg [3:0] number[0:7];
reg [3:0] no;
reg onehz;
reg trigger;



initial begin
 number[0] = 2;
 number[1] = 3;
 number[2] = 10;
 number[3] = 5;
 number[4] = 9;
 number[5] = 10;
 number[6] = 5;
 number[7] = 1;
end

//-------counter1--------
always @ (posedge clk)
begin
if(counter1 == 26'd25000000)
begin
counter1 <= 26'd0;
onehz <= ~onehz;
end
else
 counter1 <= counter1 + 1'b1;
end

//------block2:decoder + modify seg-----
always @ (counter1[17:15])
begin
 case(counter1[17:15])
  3'b000 : if ((state==S1)&&(counter1[21]==0))dig=8'b11111111;else dig = 8'b01111111;
  3'b001 : if ((state==S1)&&(counter1[21]==0))dig=8'b11111111;else dig = 8'b10111111;
  3'b010 : dig = 8'b11011111;
  3'b011 : if ((state==S2)&&(counter1[21]==0))dig=8'b11111111;else dig = 8'b11101111;
  3'b100 : if ((state==S2)&&(counter1[21]==0))dig=8'b11111111;else dig = 8'b11110111;
  3'b101 : dig = 8'b11111011;
  3'b110 : if ((state==S3)&&(counter1[21]==0))dig=8'b11111111;else dig = 8'b11111101;
  3'b111 : if ((state==S3)&&(counter1[21]==0))dig=8'b11111111;else dig = 8'b11111110;
 endcase
 
 no=number[counter1[17:15]];

case(no)
 4'h0 : seg = 8'hc0;//"0"
 4'h1 : seg = 8'hf9;//"1"
 4'h2 : seg = 8'ha4;//"2"
 4'h3 : seg = 8'hb0;//"3"
 4'h4 : seg = 8'h99;//"4"
 4'h5 : seg = 8'h92;//"5"
 4'h6 : seg = 8'h82;//"6"
 4'h7 : seg = 8'hf8;//"7"
 4'h8 : seg = 8'h80;//"8"
 4'h9 : seg = 8'h90;//"9"
 4'ha : seg = 8'hBF;//"-"
endcase
end

always @ (negedge trigger)
begin

if(state == S0)
	begin
	if(number[7] == 9)
	 begin
		number[7]<=0;
		if(number[6] == 5)
		begin
			number[6]<=0;
			if(number[4]==9)
			begin
				number[4]<=0;
				if(number[3]==5)
				begin
					number[3]<=0;
					if(number[1]==3)
					begin
						number[1]<=0;
						if(number[0]==2)
						begin
							number[0]<=0;
							number[1]<=0;
						end
						else
						number[0]<=number[0]+1;
					end
					else
					number[1]<=number[1]+1;
				end
				else
				number[3]<=number[3]+1;
			end
			else
			number[4]<=number[4]+1;
		end
		else
		number[6]<=number[6]+1;
	 end
	 else
		number[7]<=number[7]+1;
	end
	
	if(state == S1)
	begin
		if(key[4]==0)
		begin
			if(number[1]==9)
			begin
				number[1]<=0;
				if(number[0]==2)
				begin
					number[0]<=0;
					number[1]<=0;
				end
				else
				number[0]<=number[0]+1;
			end
		else
			number[1]<=number[1]+1;
		end
		end
	if(state == S1)
	begin
		if(key[5]==0)
		begin
			if(number[1]==0)
			begin
				number[1]<=9;
				if(number[0]==0)
				begin
					number[0]<=2;
					number[1]<=3;
				end
				else
				number[0]<=number[0]-1;
		end
		else
			number[1]<=number[1]-1;
  end
  end
	
	if(state == S2)
		begin
			if(key[4]==0)
			begin
				if(number[4]==9)
				begin
					number[4]<=0;
					if(number[3]==5)
					begin
						number[3]<=0;
						number[4]<=0;
					end
					else
					number[3]<=number[3]+1;
				end
			else
				number[4]<=number[4]+1;
			end
			end
			
	if(state == S2)
		begin
			if(key[5]==0)
				begin
					if(number[4]==0)
					begin
						number[4]<=9;
						if(number[3]==0)
						begin
							number[3]<=5;
							number[4]<=9;
						end
						else
						number[3]<=number[3]-1;
				end
				else
					number[4]<=number[4]-1;
		end
		end
	
	if(state == S3)
		begin
			if(key[4]==0)
			begin
				if(number[7]==9)
				begin
					number[7]<=0;
					if(number[6]==5)
					begin
						number[6]<=0;
						number[7]<=0;
					end
					else
					number[6]<=number[6]+1;
				end
			else
				number[7]<=number[7]+1;
			end
			end
			
	if(state == S3)
		begin
			if(key[5]==0)
			begin
				if(number[7]==0)
				begin
					number[7]<=9;
					if(number[6]==0)
					begin
						number[6]<=5;
						number[7]<=9;
					end
					else
					number[6]<=number[6]-1;
			end
			else
				number[7]<=number[7]-1;
	end
	end
end


reg[1:0] state,next_state;
parameter S0=2'b00,S1=2'b01,S2=2'b10,S3=2'b11;

always @ (negedge key[6])
begin
  state <= next_state;
end
  
always @ (state)
begin
 case(state)
  S0:next_state = S1;
  S1:next_state = S2;
  S2:next_state = S3;
  S3:next_state = S0;
 endcase
 
 case(state)
  S0:led=8'b01111111;
  S1:led=8'b10111111;
  S2:led=8'b11011111;
  S3:led=8'b11101111;
 endcase
 case(state)
	S0: trigger = onehz;
	S1,S2,S3: trigger = (out1 & out2);
endcase
end
 

debouncing1 A0(key[4],out1,counter1[9]);
debouncing1 A1(key[5],out2,counter1[9]);


endmodule
  