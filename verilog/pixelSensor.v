//====================================================================
//        Copyright (c) 2021 Carsten Wulff Software, Norway
// ===================================================================
// Created       : wulff at 2021-7-21
// ===================================================================
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//====================================================================

//----------------------------------------------------------------
// Model of pixel sensor, including
//  - Reset
//  - The sensor
//  - Comparator
//  - Memory latch
//  - Readout of latched value
//----------------------------------------------------------------
module PIXEL_SENSOR
  (
   input logic      VBN1,        // Amount of posedges decides how low photodiode is
   input logic      RAMP,
   input logic      RESET,       // Reset voltage in paper, this variable is not used
   input logic      ERASE,       // Pixel reset in paper
   input logic      EXPOSE,      // PG in paper
   input logic      READ,        // Read in paper
   inout [BIT_DEPTH - 1:0] DATA

   );

   parameter integer BIT_DEPTH = 8;

   real             v_erase = 2.0;
   real             lsb = v_erase/(2**BIT_DEPTH - 1);
   real             lsb_expose = v_erase/255;
   parameter real   dv_pixel = 0.5;

   real             tmp;
   logic            cmp;
   real             adc;

   logic [BIT_DEPTH - 1:0]      p_data;

   //----------------------------------------------------------------
   // ERASE
   //----------------------------------------------------------------
   // Reset the pixel value on pixRst
   always @(ERASE) begin
      tmp = v_erase;
      p_data = 0;
      cmp  = 1;
      adc = 0;
   end

   //----------------------------------------------------------------
   // SENSOR
   //----------------------------------------------------------------
   // Use bias to provide a clock for integration when exposing
   always @(posedge VBN1) begin
      if(EXPOSE)
        tmp = tmp - dv_pixel*lsb_expose;
   end

   //----------------------------------------------------------------
   // Comparator
   //----------------------------------------------------------------
   // Use ramp to provide a clock for ADC conversion, assume that ramp
   // and DATA are synchronous
   always @(posedge RAMP) begin
      adc = adc + lsb;
      if(adc > tmp)
        cmp <= 0;
   end

   //----------------------------------------------------------------
   // Memory latch
   //----------------------------------------------------------------
   always_comb  begin
      if(cmp) begin
         p_data = DATA;
      end
   end

   //----------------------------------------------------------------
   // Readout
   //----------------------------------------------------------------
   // Assign data to bus when pixRead = 1
   // The readout of the memory inverts the data
   assign DATA = READ ? ~p_data : 'Z;

endmodule // re_control
