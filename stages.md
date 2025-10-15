# Stages and their working
1. IF
- PC points at instruction to Fetch from memory
- access instruction memory and return its word
- increment PC
- If branch or jump correct later

2. ID Stage
- Decode instruction into opcode, funct3/7, rs1/2, rd
- generate control signals
- Read regfile and fetch operaands
- gennerate immediate

3. EX Stage
- Perform ALU operations
- For memory instructions compute effective address (base + offset)
- For branch/jump calculate traget address and check if branch is taken

3. MEM Stage
- For load read data memory to compute address
- for store data is taken from rs2 and written to data memory
- for others pass the alu result

4. WB Stage
- write back final into regfile
- for arithmetic/logical write to rd
- for load read data from memory and write to rd

