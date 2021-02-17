#!/usr/bin/python

##
##  Written 2010-10-07 by Eddie F.
##
##  For outputting a dat file in CSV format
##  (according to fmt file info).
##
##  Use the dat file as the argument.
##
##  This CSV data could then be pasted into excel for any required
##  text manipulation, filtering and sorting.
##


#
##  Delimiter
value_delim = ","
#value_delim = ";"
#value_delim = ""

#
##  Delimiter
#entry_delim = ","
#entry_delim = ";"
entry_delim = ""


import os
import sys



if len(sys.argv) < 2:
  print("")
  print("  Need the dat file as the argument.")
  print("")
  
elif len(sys.argv) > 2:
  print("")
  print("  Too many arguments. Just need to specify the dat file to process.")
  print("")
  
else:
  #dat_file_name = "c_pos.dat"
  dat_file_name = sys.argv[1]
  #print("dat_file = " + dat_file_name)
  fmt_file_name = dat_file_name[:len(dat_file_name)-3] + "fmt"
  #print("fmt_file = " + fmt_file_name)
  #print("")

  try:
    fmt_file = open(fmt_file_name, "r")
  except:
    print("")
    print("  Can't open the dat file.")
    print("  Need to be in the apropriate opdirs directory.")
    print("")
    print("")

  dictionary_section = False
  dictionary = list()
  for fmt_line in fmt_file:
    fmt_line = fmt_line.replace('\n', "")
    if fmt_line != "":
      if dictionary_section:
        words = fmt_line.split()
        entry_desc = words[0]
        entry_start = int(words[3])
        entry_end = int(words[3]) + int(words[4])
        dictionary.append([entry_desc, entry_start, entry_end])
      if fmt_line.find("# Dictionary") == 0:
        dictionary_section = True
    else:
      dictionary_section = False

  #print("  Dictionary...")
  #for item in dictionary:
  #  print(item)
  #print("")

  fmt_file.close()

  try:
    dat_file = open(dat_file_name, "r")
  except:
    print("")
    print("  Can't open the fmt file.")
    print("  Need to be in the apropriate opdirs directory.")
    print("")
    print("")

  output_line = ""
  for i in range(0, len(dictionary)):
    output_line = output_line + (dictionary[i])[0]
    if i != (len(dictionary)-1):
      output_line = output_line + value_delim
  output_line = output_line + entry_delim
  print(output_line)
  
  for dat_line in dat_file:
    dat_line = dat_line.replace('\n', "")
    output_line = ""
    if dat_line != "":
      for i in range(0, len(dictionary)):
        #output_line = output_line + (dat_line[int((dictionary[i])[1]):int((dictionary[i])[2])])
        #output_line = output_line + (dat_line[int((dictionary[i])[1]):int((dictionary[i])[2])]).strip()
        output_line = output_line + "\"" + (dat_line[int((dictionary[i])[1]):int((dictionary[i])[2])]).strip() + "\"" 
        if i != (len(dictionary)-1):
          output_line = output_line + value_delim
      output_line = output_line + entry_delim
      print(output_line)
    else:
      print("  ... Blank line...")

  dat_file.close()
