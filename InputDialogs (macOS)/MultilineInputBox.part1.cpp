/*****************************************************************************
 
 MIT License
 
 Copyright © 2019 Samuel Venable
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 *****************************************************************************/

#include <string>
using std::string;

extern "C" double cocoa_dialog_cancelled();
extern "C" const char *cocoa_dialog_inputbox(const char *str, const char *def, double multiline, void *owner, double owner_enabled, double has_caption,
                                             const char *caption, const char *button1, const char *button2, double embedded, double width, double height,
                                             double fontsize, double disableinput, double hiddeninput, double numbersonly);

#define EXPORTED_FUNCTION extern "C" __attribute__((visibility("default")))

namespace global_variables
{
    double dialog_is_multiline = 0;
    void *dialog_get_owner = NULL;
    double dialog_owner_is_enabled = 1;
    double dialog_has_caption = 1;
    string dialog_get_caption;
    string dialog_get_button1;
    string dialog_get_button2;
    double dialog_is_embedded = 0;
    double dialog_get_width = 320;
    double dialog_get_height = 240;
    double dialog_get_fontsize = 15;
    double dialog_get_disableinput = 0;
    double dialog_get_hiddeninput = 0;
    double dialog_get_numbersonly = 0;
}

EXPORTED_FUNCTION double dialog_owner(void *owner)
{
    global_variables::dialog_get_owner = owner;
    
    return 0;
}

EXPORTED_FUNCTION double dialog_caption(double show, char *str)
{
    global_variables::dialog_has_caption = show;
    global_variables::dialog_is_embedded = !show;
    global_variables::dialog_owner_is_enabled = !show;
    global_variables::dialog_get_caption = str;
    
    return 0;
}

EXPORTED_FUNCTION double dialog_buttons(char *btn1, char *btn2)
{
    global_variables::dialog_get_button1 = btn1;
    global_variables::dialog_get_button2 = btn2;
    
    return 0;
}

EXPORTED_FUNCTION double dialog_size(double width, double height)
{
    global_variables::dialog_get_width = width;
    global_variables::dialog_get_height = height;
    
    return 0;
}

EXPORTED_FUNCTION double dialog_fontsize(double fontsize)
{
    global_variables::dialog_get_fontsize = fontsize;
    
    return 0;
}

EXPORTED_FUNCTION double dialog_disableinput(double disableinput)
{
    global_variables::dialog_get_disableinput = disableinput;
    
    return 0;
}

EXPORTED_FUNCTION double dialog_hiddeninput(double hiddeninput)
{
    global_variables::dialog_get_hiddeninput = hiddeninput;
    
    return 0;
}

EXPORTED_FUNCTION double dialog_numbersonly(double numbersonly)
{
    global_variables::dialog_get_numbersonly = numbersonly;
    
    return 0;
}

EXPORTED_FUNCTION double dialog_cancelled()
{
    return cocoa_dialog_cancelled();
}

EXPORTED_FUNCTION char *dialog_inputbox(char *str, char *def, double multiline)
{
    string str_dialog_get_message = str;
    string str_dialog_get_default = def;
    
    return (char *)cocoa_dialog_inputbox(str_dialog_get_message.c_str(), str_dialog_get_default.c_str(), multiline,
                                         global_variables::dialog_get_owner, global_variables::dialog_owner_is_enabled,
                                         global_variables::dialog_has_caption, global_variables::dialog_get_caption.c_str(),
                                         global_variables::dialog_get_button1.c_str(), global_variables::dialog_get_button2.c_str(),
                                         global_variables::dialog_is_embedded, global_variables::dialog_get_width,
                                         global_variables::dialog_get_height, global_variables::dialog_get_fontsize,
                                         global_variables::dialog_get_disableinput, global_variables::dialog_get_hiddeninput,
                                         global_variables::dialog_get_numbersonly);
}
