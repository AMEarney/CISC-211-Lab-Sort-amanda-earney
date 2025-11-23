/*** asmSort.s   ***/
.syntax unified

/* Declare the following to be in data memory */
.data
.align    

/* Define the globals so that the C code can access them */
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Amanda Earney"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/********************************************************************
function name: asmSwap(inpAddr,signed,elementSize)
function description:
    Checks magnitude of each of two input values 
    v1 and v2 that are stored in adjacent in 32bit memory words.
    v1 is located in memory location (inpAddr)
    v2 is located at mem location (inpAddr + M4 word size)
    
    If v1 or v2 is 0, this function immediately
    places -1 in r0 and returns to the caller.
    
    Else, if v1 <= v2, this function 
    does not modify memory, and returns 0 in r0. 

    Else, if v1 > v2, this function 
    swaps the values and returns 1 in r0

Inputs: r0: inpAddr: Address of v1 to be examined. 
	             Address of v2 is: inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: size: number of bytes for each input value.
                  Valid values: 1, 2, 4
                  The values v1 and v2 are stored in
                  the least significant bits at locations
                  inpAddr and (inpAddr + M4 word size).
                  Any bits not used in the word may be
                  set to random values. They should be ignored
                  and must not be modified.
Outputs: r0 returns: -1 If either v1 or v2 is 0
                      0 If neither v1 or v2 is 0, 
                        and a swap WAS NOT made
                      1 If neither v1 or v2 is 0, 
                        and a swap WAS made             
             
         Memory: if v1>v2:
			swap v1 and v2.
                 Else, if v1 == 0 OR v2 == 0 OR if v1 <= v2:
			DO NOT swap values in memory.

NOTE: definitions: "greater than" means most positive number
********************************************************************/     
.global asmSwap
.type asmSwap,%function     
asmSwap:

    /* REMEMBER TO FOLLOW THE ARM CALLING CONVENTION!            */

    /* YOUR asmSwap CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11, LR}

    LDR r4, =0
    CMP r1, r4 /* checks for signed or unsigned numbers */
    BEQ checkUnsignedSize
    B checkSignedSize
    
checkUnsignedSize:
    LDR r4, =1
    CMP r2, r4 /* checks if the size is 1 byte */
    BEQ unsignedByte
    LDR r4, =2
    CMP r2, r4 /* checks if the size is a halfword */
    BEQ unsignedHalfword
    LDR r5, [r0] /* gets the value of v1 in r5 */
    LDR r6, [r0, 4] /* gets the value of v2 in r6 without incrementing r0 */
    B checkUnsignedValues
    
unsignedByte:
    LDRB r5, [r0] /* puts the correctly sized value of v1 into r5 */
    LDRB r6, [r0, 4] /* puts v2 into r6 without incrementing r0 */
    B checkUnsignedValues
    
unsignedHalfword:
    LDRH r5, [r0] /* puts the correctly sized value of v1 into r5 */
    LDRH r6, [r0, 4] /* puts v2 into r6 without incrementing r0 */
    B checkUnsignedValues
    
checkSignedSize:
    LDR r4, =1
    CMP r2, r4 /* checks if the size is 1 byte */
    BEQ signedByte
    LDR r4, =2
    CMP r2, r4 /* checks if the size is a halfword */
    BEQ signedHalfword
    LDR r5, [r0] /* gets the value of v1 in r5 */
    LDR r6, [r0, 4] /* gets the value of v2 in r6 without incrementing r0 */
    B checkSignedValues
    
signedByte:
    LDRSB r5, [r0] /* puts the correctly sized value of v1 into r5 with sign extension */
    LDRSB r6, [r0, 4] /* puts v2 into r6 without incrementing r0 */
    B checkSignedValues
    
signedHalfword:
    LDRSH r5, [r0] /* puts the correctly sized value of v1 into r5 with sign extension */
    LDRSH r6, [r0, 4] /* puts v2 into r6 without incrementing r0 */
    B checkSignedValues
    
checkUnsignedValues:
    LDR r4, =0
    CMP r5, r4 /* checks if v1 is 0 */
    CMPNE r6, r4 /* if v1 != 0, checks if v2 is 0 */
    MOVEQ r0, -1 /* if either is 0, puts -1 in return register */
    BEQ exitSwap 
    CMP r5, r6 /* checks which value is greater */
    MOVLS r0, 0 /* if v1 is less than or equal to v2, puts 0 in return register */
    BLS exitSwap /* using LS because of unsigned values */
    B swapValues /* if got here, values should be swapped */
    
checkSignedValues:
    LDR r4, =0
    CMP r5, r4 /* checks if v1 is 0 */
    CMPNE r6, r4 /* if v1 != 0, checks if v2 is 0 */
    MOVEQ r0, -1 /* if either is 0, puts -1 in return register */
    BEQ exitSwap
    CMP r5, r6 /* checks which value is greater */
    MOVLE r0, 0 /* if v1 is less than or equal to v2, puts 0 in return register */
    BLE exitSwap /* using LE because of signed values */
    B swapValues /* if got here, values should be swapped */
    
swapValues:
    MOV r7, r5 /* stores value of v1 into a temporary register */
    MOV r5, r6 /* overrides value of v1 with value of v2 */
    MOV r6, r7 /* overrides value of v2 with stored value of v1 */
    LDR r4, =1
    CMP r2, r4 /* checks if size of values are 1 byte */
    BEQ storeBytes
    LDR r4, =2 
    CMP r2, r4 /* checks if size of values are a halfword */
    BEQ storeHalfwords
    STR r5, [r0] /* stores lower value into first address */
    STR r6, [r0, 4] /* stores higher value into second address */
    /* not autoindexing for consistency with instances without swapping */
    MOV r0, 1
    B exitSwap
    
storeBytes:
    STRB r5, [r0] /* stores lower value into first address */
    STRB r6, [r0, 4] /* stores higher value into second address */
    /* not autoindexing for consistency with instances without swapping */
    MOV r0, 1
    B exitSwap
    
storeHalfwords:
    STRH r5, [r0] /* stores lower value into first address */
    STRH r6, [r0, 4] /* stores higher value into second address */
    /* not autoindexing for consistency with instances without swapping */
    MOV r0, 1
    
exitSwap:
    pop {r4-r11, LR}
    BX LR
    /* YOUR asmSwap CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */
    
    
/********************************************************************
function name: asmSort(startAddr,signed,elementSize)
function description:
    Sorts value in an array from lowest to highest.
    The end of the input array is marked by a value
    of 0.
    The values are sorted "in-place" (i.e. upon returning
    to the caller, the first element of the sorted array 
    is located at the original startAddr)
    The function returns the total number of swaps that were
    required to put the array in order in r0. 
    
         
Inputs: r0: startAddr: address of first value in array.
		      Next element will be located at:
                          inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: elementSize: number of bytes for each input value.
                          Valid values: 1, 2, 4
Outputs: r0: number of swaps required to sort the array
         Memory: The original input values will be
                 sorted and stored in memory starting
		 at mem location startAddr
NOTE: definitions: "greater than" means most positive number    
********************************************************************/     
.global asmSort
.type asmSort,%function
asmSort:   

    /* REMEMBER TO FOLLOW THE ARM CALLING CONVENTION!            */

    /* YOUR asmSort CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11, LR}

    LDR r4, =0 /* r4 will store the swap amount */
    MOV r5, r0 /* a copy of the start address will be stored in r5 */
    MOV r6, r0 /* puts a copy of the input address into r6 to increment */
    LDR r7, =1 /* values for checking results of swap */
    LDR r8, =-1 
    LDR r9, =1 /* r9 holds a boolean for if a swap happened */
    
sortLoop:
    CMP r9, r7 
    BNE exitSort /* if r9 is still 0, a swap never happened */
    LDR r9, =0 /* resets swap happened boolean to 0 */
    MOV r0, r5 /* resets the address input to the start address */
    MOV r6, r5 /* resets the incremented input address */
    
sortSwap:
    BL asmSwap
    CMP r0, r7 /* checks if values were swapped */
    LDREQ r9, =1 /* sets bool to true if swapped */
    ADDEQ r4, r4, 1 /* increments swap amount by 1 if swapped */
    CMP r0, r8 /* checks if either value was 0 */
    BEQ sortLoop /* restarts outer loop if a value was 0 */
    ADD r6, r6, 4 /* increments the input address */
    MOV r0, r6 /* moves the incremented input address into r0 */
    B sortSwap /* checks the next 2 values */
    
exitSort:
    MOV r0, r4 /* puts the swap amount into the return register */
    pop {r4-r11, LR}
    BX LR
    /* YOUR asmSort CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




