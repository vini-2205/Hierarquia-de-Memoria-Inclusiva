module Pratica1Parte3 (
  address,
  clock,
  data,
  wren,
  q,
  hit_saida,
  data_writeback_mem,
  address_writeback_mem,
  saida_via1,
  saida_via2
);

input [4:0] address;
input clock;
input [2:0] data;
input wren;
output [2:0] q;
output hit_saida;
output [2:0]data_writeback_mem;
output [4:0]address_writeback_mem;
output [8:0] saida_via1;
output [8:0] saida_via2;

wire [2:0] q_mem;
reg [2:0]sub_data_writeback_mem;
reg [4:0]sub_address_writeback_mem;

//auxiliares para a memoria
reg [4:0] sub_address_mem;
reg [2:0] sub_data_mem;
reg sub_wren;
reg [8:0] via1;
reg [8:0] via2;


  
memoria_principal memoria(
  sub_address_mem,
  clock,
  sub_data_mem,
  sub_wren,
  q_mem
);

//registradores para o código
reg [2:0] data_saida;
reg valido = 0;
reg hit=0;
reg [2:0] retorno;
reg [2:0] data_retorno;
  
//wire para utilizar jno código
wire [1:0] index = address[1:0];
wire [2:0] tag = address[4:2];

reg [8:0] via[1:0][3:0];  // 0(valid) 0(lru) 0(dirty) 000(tag) 000(data) 

initial begin
  //inicialização das posições de memória conforme o caso teste
  via[0][0] = 9'b000100011;
  via[1][0] = 9'b110101100;
  via[0][1] = 9'b100000011;
  via[1][1] = 9'b110001111;
  via[0][2] = 9'bxxxxxxxxx;
  via[1][2] = 9'bxxxxxxxxx;
  via[0][3] = 9'b110xxx011;
  via[1][3] = 9'bxxxxxxxxx;

end

always @(negedge clock) begin

  hit = 0;
  $display("tag: %b index:%b valido:%b", tag,index,valido);
  if (wren == 0) begin

    //acesso caminho 1
    if (index == 0) begin
      //acesso via0
      if (via[0][0][8] == 1) begin //valido da via é 1
        if(tag == via[0][0][5:3]) begin
          data_saida = via[0][0][2:0];  //le a data
          hit = 1;  //hit é 1
          via[0][0][7] = 1;  //lru é 1 
          if(via[1][0][7]==1)begin //se o lru da via 2 for 1
            via[1][0][7] = 0;  //lru vale 0
          end
        end
      end 
      //acesso via1
      else if (via[1][0][8] == 1) begin
        if (tag == via[1][0][5:3]) begin
          data_saida = via[1][0][2:0];
          hit = 1;
          via[1][0][7] = 1;
          if (via[0][0][7] == 1) begin
            via[0][0][7] = 0;
          end
        end
      end
  
      //caso tenha dado miss
      if(hit==0) begin
        if(valido==0) begin
          sub_address_mem = address[3:0];
          sub_data_mem = data;
          sub_wren = 0;
          valido = 1;
        end
        //escrita na cache
        else begin
          data_retorno = q_mem;
          valido = 0;
        end

          //se lru for 0 da primeira via
          if(via[0][0][7] == 0 && valido==0) begin
            if(via[0][0][6] == 1)begin
              sub_address_mem = {via[0][0][4:3], 2'b00};
              sub_data_mem = via[0][0][2:0];
              sub_wren = 1;
            end

            via[0][0][2:0] = data_retorno;
            via[0][0][5:3] = address[4:2];  //novo addres é colocado
            data_saida = via[0][0][2:0]; //data saida é colocado
            via[0][0][7] = 1;  //lru é 1 
            via[0][0][6] = 0;  //dirty é 1
            if(via[1][0][7]==1) begin//se o lru da via 2 for 1
              via[1][0][7] = 0;  //lru vale 0
            end
            if(via[0][0][2:0]==data_retorno)begin //colocar o valido como 1
              via[0][0][8] = 1;  //valido é 1
            end
        end
          //se o lru da segunda for 0
          else if (via[1][0][7] == 0 && valido==0) begin
            if(via[1][0][6] == 1)begin
              sub_address_mem = {via[1][0][4:3], 2'b00};
              sub_data_mem = via[1][0][2:0];
              sub_wren = 1;
            end
            via[1][0][2:0] = data_retorno;
            via[1][0][5:3] = address[4:2];  //novo addres é colocado
            data_saida = via[1][0][2:0]; //data saida é colocado
            via[1][0][7] = 1;  //lru é 1 
            via[1][0][6] = 0;  //dirty é 1
            if(via[0][0][7]==1) begin//se o lru da via 2 for 1
              via[0][0][7] = 0;  //lru vale 0
            end
            if(via[1][0][2:0]==data_retorno)begin //colocar o valido como 1
              via[1][0][8] = 1;  //valido é 1
            end
        end
      end 
		  via1 = via[0][0];
		  via2 = via[1][0];
    end

    if (index == 1) begin
      //acesso via0
      if (via[0][1][8] == 1) begin //valido da via é 1
        if(tag == via[0][1][5:3]) begin
          data_saida = via[0][1][2:0];  //le a data
          hit = 1;  //hit é 1
          via[0][1][7] = 1;  //lru é 1 
          if(via[1][1][7]==1)begin //se o lru da via 2 for 1
            via[1][1][7] = 0;  //lru vale 0
          end
        end
      end 
      //acesso via1
      else if (via[1][1][8] == 1) begin
        if (tag == via[1][1][5:3]) begin
          data_saida = via[1][1][2:0];
          hit = 1;
          via[1][1][7] = 1;
          if (via[0][1][7] == 1) begin
            via[0][1][7] = 0;
          end
        end
      end
  
      //caso tenha dado miss
      if(hit==0) begin
        if(valido==0) begin
          sub_address_mem = address[3:0];
          sub_data_mem = data;
          sub_wren = 0;
          valido = 1;
			 $display("address_mem: %b data_mem:%b ",sub_address_mem,sub_data_mem);
        end
        //escrita na cache
        else begin
          data_retorno = q_mem;
          valido = 0;
        end

          //se lru for 0 da primeira via
          if(via[0][1][7] == 0 && valido==0) begin
            if(via[0][1][6] == 1)begin
              sub_address_mem = {via[0][1][4:3], 2'b01};
              sub_data_mem = via[0][1][2:0];
              sub_wren = 1;
				  sub_address_writeback_mem = sub_address_mem;
				  sub_data_writeback_mem = sub_data_mem;
            end

            via[0][1][2:0] = data_retorno;
			via[0][1][5:3] = address[4:2];  //novo addres é colocado
            data_saida = via[0][1][2:0]; //data saida é colocado
            via[0][1][7] = 1;  //lru é 1 
            via[0][1][6] = 0;  //dirty é 1
            if(via[1][1][7]==1) begin//se o lru da via 2 for 1
              via[1][1][7] = 0;  //lru vale 0
            end
            if(via[0][1][2:0]==data_retorno)begin //colocar o valido como 1
              via[0][1][8] = 1;  //valido é 1
            end
        end
          //se o lru da segunda for 0
          else if (via[1][1][7] == 0 && valido==0) begin
            if(via[1][1][6] == 1)begin
              sub_address_mem = {via[1][1][4:3], 2'b01};
              sub_data_mem = via[1][1][2:0];
              sub_wren = 1;
				  sub_address_writeback_mem = sub_address_mem;
				  sub_data_writeback_mem = sub_data_mem;
            end
            via[1][1][2:0] = data_retorno;
            via[1][1][5:3] = address[4:2];  //novo addres é colocado
            data_saida = via[1][1][2:0]; //data saida é colocado
            via[1][1][7] = 1;  //lru é 1 
            via[1][1][6] = 0;  //dirty é 1
            if(via[0][1][7]==1) begin//se o lru da via 2 for 1
              via[0][1][7] = 0;  //lru vale 0
            end
            if(via[1][1][2:0]==data_retorno)begin //colocar o valido como 1
              via[1][1][8] = 1;  //valido é 1
            end
        end
      end
		  via1 = via[0][1];
		  via2 = via[1][1];
    end

    if (index == 2) begin
      //acesso via0
      if (via[0][2][8] == 1) begin //valido da via é 1
        if(tag == via[0][2][5:3]) begin
          data_saida = via[0][2][2:0];  //le a data
          hit = 1;  //hit é 1
          via[0][2][7] = 1;  //lru é 1 
          if(via[1][2][7]==1)begin //se o lru da via 2 for 1
            via[1][2][7] = 0;  //lru vale 0
          end
        end
      end 
      //acesso via1
      else if (via[1][2][8] == 1) begin
        if (tag == via[1][2][5:3]) begin
          data_saida = via[1][2][2:0];
          hit = 1;
          via[1][2][7] = 1;
          if (via[0][2][7] == 1) begin
            via[0][2][7] = 0;
          end
        end
      end
  
      //caso tenha dado miss
      if(hit==0) begin
        if(valido==0) begin
          sub_address_mem = address[3:0];
          sub_data_mem = data;
          sub_wren = 0;
          valido = 1;
        end
        //escrita na cache
        else begin
          data_retorno = q_mem;
          valido = 0;
        end

          //se lru for 0 da primeira via
          if(via[0][2][7] == 0 && valido==0) begin
            if(via[0][2][6] == 1)begin
              sub_address_mem = {via[0][2][4:3], 2'b10};
              sub_data_mem = via[0][2][2:0];
              sub_wren = 1;
            end

            via[0][2][2:0] = data_retorno;
            via[0][2][5:3] = address[4:2];  //novo addres é colocado
            data_saida = via[0][2][2:0]; //data saida é colocado
            via[0][2][7] = 1;  //lru é 1 
            via[0][2][6] = 0;  //dirty é 1
            if(via[1][2][7]==1) begin//se o lru da via 2 for 1
              via[1][2][7] = 0;  //lru vale 0
            end
            if(via[0][2][2:0]==data_retorno)begin //colocar o valido como 1
              via[0][2][8] = 1;  //valido é 1
            end
        end
          //se o lru da segunda for 0
          else if (via[1][2][7] == 0 && valido==0) begin
            if(via[1][2][6] == 1)begin
              sub_address_mem = {via[1][2][4:3], 2'b10};
              sub_data_mem = via[1][2][2:0];
              sub_wren = 1;
            end
            via[1][2][2:0] = data_retorno;
            via[1][2][5:3] = address[4:2];  //novo addres é colocado
            data_saida = via[1][2][2:0]; //data saida é colocado
            via[1][2][7] = 1;  //lru é 1 
            via[1][2][6] = 0;  //dirty é 1
            if(via[0][2][7]==1) begin//se o lru da via 2 for 1
              via[0][2][7] = 0;  //lru vale 0
            end
            if(via[1][2][2:0]==data_retorno)begin //colocar o valido como 1
              via[1][2][8] = 1;  //valido é 1
            end
        end
      end 
		via1 = via[0][2];
		via2 = via[1][2];
    end

    if (index == 3) begin
      //acesso via0
      if (via[0][3][8] == 1) begin //valido da via é 1
        if(tag == via[0][3][5:3]) begin
          data_saida = via[0][3][2:0];  //le a data
          hit = 1;  //hit é 1
          via[0][3][7] = 1;  //lru é 1 
          if(via[1][3][7]==1)begin //se o lru da via 2 for 1
            via[1][3][7] = 0;  //lru vale 0
          end
        end
      end 
      //acesso via1
      else if (via[1][3][8] == 1) begin
        if (tag == via[1][3][5:3]) begin
          data_saida = via[1][3][2:0];
          hit = 1;
          via[1][3][7] = 1;
          if (via[0][3][7] == 1) begin
            via[0][3][7] = 0;
          end
        end
      end
  
      //caso tenha dado miss
      if(hit==0) begin
        if(valido==0) begin
          sub_address_mem = address[3:0];
          sub_data_mem = data;
          sub_wren = 0;
          valido = 1;
        end
        //escrita na cache
        else begin
          data_retorno = q_mem;
          valido = 0;
        end

          //se lru for 0 da primeira via
          if(via[0][3][7] == 0 && valido==0) begin
            if(via[0][3][6] == 1)begin
              sub_address_mem = {via[0][3][4:3], 2'b11};
              sub_data_mem = via[0][3][2:0];
              sub_wren = 1;
            end

            via[0][3][2:0] = data_retorno;
            via[0][3][5:3] = address[4:2];  //novo addres é colocado
            data_saida = via[0][3][2:0]; //data saida é colocado
            via[0][3][7] = 1;  //lru é 1 
            via[0][3][6] = 0;  //dirty é 1
            if(via[1][3][7]==1) begin//se o lru da via 2 for 1
              via[1][3][7] = 0;  //lru vale 0
            end
            if(via[0][3][2:0]==data_retorno)begin //colocar o valido como 1
              via[0][3][8] = 1;  //valido é 1
            end
        end
          //se o lru da segunda for 0
          else if (via[1][3][7] == 0 && valido==0) begin
            if(via[1][3][6] == 1)begin
              sub_address_mem = {via[1][3][4:3], 2'b11};
              sub_data_mem = via[1][3][2:0];
              sub_wren = 1;
            end
            via[1][3][2:0] = data_retorno;
            via[1][3][5:3] = address[4:2];  //novo addres é colocado
            data_saida = via[1][3][2:0]; //data saida é colocado
            via[1][3][7] = 1;  //lru é 1 
            via[1][3][6] = 0;  //dirty é 1
            if(via[0][3][7]==1) begin//se o lru da via 2 for 1
              via[0][3][7] = 0;  //lru vale 0
            end
            if(via[1][3][2:0]==data_retorno)begin //colocar o valido como 1
              via[1][3][8] = 1;  //valido é 1
            end
        end
      end
		  via1 = via[0][3];
		  via2 = via[1][3];	
    end  
  end


  //caso instrução seja de escrita
  if(wren==1)begin
    //acesso caminho 1
    if (index == 0) begin
      //acesso via0
      if(via[0][0][8] == 1) begin //valido da via é 1
        if(tag == via[0][0][5:3]) begin
          via[0][0][2:0] = data;  //le a data
          data_saida = via[0][0][2:0];
          hit = 1;  //hit é 1
          via[0][0][7] = 1;  //lru é 1 
          via[0][0][6] = 1;
          if(via[1][0][7]==1)begin //se o lru da via 2 for 1
            via[1][0][7] = 0;  //lru vale 0
          end
        end
      end 

      //acesso via1
      else if (via[1][0][8] == 1) begin
        if (tag == via[1][0][5:3]) begin
          via[1][0][2:0] = data;
          data_saida = via[1][0][2:0];
          hit = 1;
          via[1][0][7] = 1;
          via[1][0][6] = 1;
          if (via[0][0][7] == 1) begin
            via[0][0][7] = 0;
          end
        end
      end

        
      //caso tenha dado miss
      if(hit==0) begin
        if(valido==0) begin
          sub_address_mem = address[3:0];
          sub_data_mem = data;
          sub_wren = 0;
          valido = 1;
        end
        //escrita na cache
        else begin
          data_retorno = q_mem;
          valido = 0;
        end

        //se lru for 0 da primeira via
        if(via[0][0][7] == 0 && valido==0) begin
          if(via[0][0][6] == 1)begin
            sub_address_mem = {via[0][0][4:3], 2'b00};
            sub_data_mem = via[0][0][2:0];
            sub_wren = 1;
          end

          via[0][0][2:0] = data_retorno;
          via[0][0][5:3] = address[4:2];  //novo addres é colocado
          via[0][0][7] = 1;  //lru é 1 
          via[0][0][6] = 1;  //dirty é 1
          via[0][0][2:0] = data;
          data_saida = via[0][0][2:0]; //data saida é colocado
          if(via[1][0][7]==1) begin//se o lru da via 2 for 1
            via[1][0][7] = 0;  //lru vale 0
          end
          if(via[0][0][2:0]==data_retorno)begin //colocar o valido como 1
            via[0][0][8] = 1;  //valido é 1
          end
        end
          
        //se o lru da segunda for 0
        else if (via[1][0][7] == 0 && valido==0) begin
          if(via[1][0][6] == 1)begin
            sub_address_mem = {via[1][0][4:3], 2'b00};
            sub_data_mem = via[1][0][2:0];
            sub_wren = 1;
          end
          via[1][0][2:0] = data_retorno;
          via[1][0][5:3] = address[4:2];  //novo addres é colocado
          data_saida = via[0][0][2:0]; //data saida é colocado
          via[1][0][7] = 1;  //lru é 1 
          via[1][0][6] = 1;  //dirty é 1
          via[1][0][2:0] = data;
          data_saida = via[1][0][2:0]; //data saida é colocado
          if(via[0][0][7]==1) begin//se o lru da via 2 for 1
            via[0][0][7] = 0;  //lru vale 0
          end
          if(via[1][0][2:0]==data_retorno)begin //colocar o valido como 1
            via[1][0][8] = 1;  //valido é 1
          end
        end
      end
		  via1 = via[0][0];
		  via2 = via[1][0];
    end

    if (index == 1) begin
      //acesso via0
      if(via[0][1][8] == 1) begin //valido da via é 1
        if(tag == via[0][1][5:3]) begin
          via[0][1][2:0] = data;  //le a data
          data_saida = via[0][1][2:0];
          hit = 1;  //hit é 1
          via[0][1][7] = 1;  //lru é 1 
          via[0][1][6] = 1;
          if(via[1][1][7]==1)begin //se o lru da via 2 for 1
            via[1][1][7] = 0;  //lru vale 0
          end
        end
      end 

      //acesso via1
      else if (via[1][1][8] == 1) begin
        if (tag == via[1][1][5:3]) begin
          via[1][1][2:0] = data;
          data_saida = via[1][1][2:0];
          hit = 1;
          via[1][1][7] = 1;
          via[1][1][6] = 1;
          if (via[0][1][7] == 1) begin
            via[0][1][7] = 0;
          end
        end
      end

        
      //caso tenha dado miss
      if(hit==0) begin
        if(valido==0) begin
          sub_address_mem = address[3:0];
          sub_data_mem = data;
          sub_wren = 0;
          valido = 1;
        end
        //escrita na cache
        else begin
          data_retorno = q_mem;
          valido = 0;
        end

        //se lru for 0 da primeira via
        if(via[0][1][7] == 0 && valido==0) begin
          if(via[0][1][6] == 1)begin
            sub_address_mem = {via[0][1][4:3], 2'b01};
            sub_data_mem = via[0][1][2:0];
            sub_wren = 1;
				sub_address_writeback_mem = sub_address_mem;
				sub_data_writeback_mem = sub_data_mem;
          end
          via[0][1][2:0] = data_retorno;
          via[0][1][5:3] = address[4:2];  //novo addres é colocado
          via[0][1][7] = 1;  //lru é 1 
          via[0][1][6] = 1;  //dirty é 1
          via[0][1][2:0] = data;
          data_saida = via[0][1][2:0]; //data saida é colocado
          if(via[1][1][7]==1) begin//se o lru da via 2 for 1
            via[1][1][7] = 0;  //lru vale 0
          end
          if(via[0][1][2:0]==data_retorno)begin //colocar o valido como 1
            via[0][1][8] = 1;  //valido é 1
          end
        end
          
        //se o lru da segunda for 0
        else if (via[1][1][7] == 0 && valido==0) begin
          if(via[1][1][6] == 1)begin
            sub_address_mem = {via[1][1][4:3], 2'b01};
            sub_data_mem = via[1][1][2:0];
            sub_wren = 1;
				sub_address_writeback_mem = sub_address_mem;
				sub_data_writeback_mem = sub_data_mem;
          end
          via[1][1][2:0] = data_retorno;
          via[1][1][5:3] = address[4:2];  //novo addres é colocado
          data_saida = via[1][1][2:0]; //data saida é colocado 
          via[1][1][6] = 1;  //dirty é 1
          via[1][1][2:0] = data;
          data_saida = via[1][1][2:0]; //data saida é colocado
          via[1][1][7] = 1;  //lru é 1
          if(via[0][1][7]==1) begin//se o lru da via 2 for 1
            via[0][1][7] = 0;  //lru vale 0
          end
          if(via[1][1][2:0]==data_retorno)begin //colocar o valido como 1
            via[1][1][8] = 1;  //valido é 1
          end
        end
      end
		via1 = via[0][1];
		  via2 = via[1][1];
    end

    if (index == 2) begin
      //acesso via0
      if(via[0][2][8] == 1) begin //valido da via é 1
        if(tag == via[0][2][5:3]) begin
          via[0][2][2:0] = data;  //le a data
          data_saida = via[0][2][2:0];
          hit = 1;  //hit é 1
          via[0][2][7] = 1;  //lru é 1 
          via[0][2][6] = 1;
          if(via[1][2][7]==1)begin //se o lru da via 2 for 1
            via[1][2][7] = 0;  //lru vale 0
          end
        end
      end 

      //acesso via1
      else if (via[1][2][8] == 1) begin
        if (tag == via[1][2][5:3]) begin
          via[1][2][2:0] = data;
          data_saida = via[1][2][2:0];
          hit = 1;
          via[1][2][7] = 1;
          via[1][2][6] = 1;
          if (via[0][2][7] == 1) begin
            via[0][2][7] = 0;
          end
        end
      end

        
      //caso tenha dado miss
      if(hit==0) begin
        if(valido==0) begin
          sub_address_mem = address[3:0];
          sub_data_mem = data;
          sub_wren = 0;
          valido = 1;
        end
        //escrita na cache
        else begin
          data_retorno = q_mem;
          valido = 0;
        end

        //se lru for 0 da primeira via
        if(via[0][2][7] == 0 && valido==0) begin
          if(via[0][2][6] == 1)begin
            sub_address_mem = {via[0][2][4:3], 2'b10};
            sub_data_mem = via[0][2][2:0];
            sub_wren = 1;
          end

          via[0][2][2:0] = data_retorno;
          via[0][2][5:3] = address[4:2];  //novo addres é colocado
          via[0][2][7] = 1;  //lru é 1 
          via[0][2][6] = 1;  //dirty é 1
          via[0][2][2:0] = data;
          data_saida = via[0][2][2:0]; //data saida é colocado
          if(via[1][2][7]==1) begin//se o lru da via 2 for 1
            via[1][2][7] = 0;  //lru vale 0
          end
          if(via[0][2][2:0]==data_retorno)begin //colocar o valido como 1
            via[0][2][8] = 1;  //valido é 1
          end
        end
          
        //se o lru da segunda for 0
        else if (via[1][2][7] == 0 && valido==0) begin
          if(via[1][2][6] == 1)begin
            sub_address_mem = {via[1][2][4:3], 2'b10};
            sub_data_mem = via[1][2][2:0];
            sub_wren = 1;
          end
          via[1][2][2:0] = data_retorno;
          via[1][2][5:3] = address[4:2];  //novo addres é colocado
          data_saida = via[0][2][2:0]; //data saida é colocado
          via[1][2][7] = 1;  //lru é 1 
          via[1][2][6] = 1;  //dirty é 1
          via[1][2][2:0] = data;
          data_saida = via[1][2][2:0]; //data saida é colocado
          if(via[0][2][7]==1) begin//se o lru da via 2 for 1
            via[0][2][7] = 0;  //lru vale 0
          end
          if(via[1][2][2:0]==data_retorno)begin //colocar o valido como 1
            via[1][2][8] = 1;  //valido é 1
          end
        end
      end
		via1 = via[0][2];
		  via2 = via[1][2];
    end

    if (index == 3) begin
      //acesso via0
      if(via[0][3][8] == 1) begin //valido da via é 1
        if(tag == via[0][3][5:3]) begin
          via[0][3][2:0] = data;  //le a data
          data_saida = via[0][3][2:0];
          hit = 1;  //hit é 1
          via[0][3][7] = 1;  //lru é 1 
          via[0][3][6] = 1;
          if(via[1][3][7]==1)begin //se o lru da via 2 for 1
            via[1][3][7] = 0;  //lru vale 0
          end
        end
      end 

      //acesso via1
      else if (via[1][3][8] == 1) begin
        if (tag == via[1][3][5:3]) begin
          via[1][3][2:0] = data;
          data_saida = via[1][3][2:0];
          hit = 1;
          via[1][3][7] = 1;
          via[1][3][6] = 1;
          if (via[0][3][7] == 1) begin
            via[0][3][7] = 0;
          end
        end
      end

        
      //caso tenha dado miss
      if(hit==0) begin
        if(valido==0) begin
          sub_address_mem = address[3:0];
          sub_data_mem = data;
          sub_wren = 0;
          valido = 1;
        end
        //escrita na cache
        else begin
          data_retorno = q_mem;
          valido = 0;
        end

        //se lru for 0 da primeira via
        if(via[0][3][7] == 0 && valido==0) begin
          if(via[0][3][6] == 1)begin
            sub_address_mem = {via[0][3][4:3], 2'b11};
            sub_data_mem = via[0][3][2:0];
            sub_wren = 1;
          end

          via[0][3][2:0] = data_retorno;
          via[0][3][5:3] = address[4:2];  //novo addres é colocado
          via[0][3][7] = 1;  //lru é 1 
          via[0][3][6] = 1;  //dirty é 1
          via[0][3][2:0] = data;
          data_saida = via[0][3][2:0]; //data saida é colocado
          if(via[1][3][7]==1) begin//se o lru da via 2 for 1
            via[1][3][7] = 0;  //lru vale 0
          end
          if(via[0][3][2:0]==data_retorno)begin //colocar o valido como 1
            via[0][3][8] = 1;  //valido é 1
          end
        end
          
        //se o lru da segunda for 0
        else if (via[1][3][7] == 0 && valido==0) begin
          if(via[1][3][6] == 1)begin
            sub_address_mem = {via[1][3][4:3], 2'b11};
            sub_data_mem = via[1][3][2:0];
            sub_wren = 1;
          end
          via[1][3][2:0] = data_retorno;
          via[1][3][5:3] = address[4:2];  //novo addres é colocado
          data_saida = via[0][3][2:0]; //data saida é colocado
          via[1][3][7] = 1;  //lru é 1 
          via[1][3][6] = 1;  //dirty é 1
          via[1][3][2:0] = data;
          data_saida = via[1][3][2:0]; //data saida é colocado
          if(via[0][3][7]==1) begin//se o lru da via 2 for 1
            via[0][3][7] = 0;  //lru vale 0
          end
          if(via[1][3][2:0]==data_retorno)begin //colocar o valido como 1
            via[1][3][8] = 1;  //valido é 1
          end
        end
      end
		via1 = via[0][3];
		  via2 = via[1][3];
    end
  end
end

assign q = data_saida;
assign hit_saida = hit;
assign data_writeback_mem = sub_data_writeback_mem;
assign address_writeback_mem = sub_address_writeback_mem;
assign saida_via1 = via1;
assign saida_via2 = via2;


endmodule