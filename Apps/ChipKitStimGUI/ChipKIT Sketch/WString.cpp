/*
  WString.cpp - String library for Wiring & Arduino
  Copyright (c) 2009-10 Hernando Barragan.  All rights reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <stdlib.h>
#include "WProgram.h"
#include "WString.h"


String::String( const char *value )
{
  if ( value == NULL )
    value = "";
  getBuffer( _length = strlen( value ) );
  if ( _buffer != NULL )
    strcpy( _buffer, value );
}

String::String( const String &value )
{
  getBuffer( _length = value._length );
  if ( _buffer != NULL )
    strcpy( _buffer, value._buffer );
}

String::String( const char value )
{
  _length = 1;
  getBuffer(1);
  if ( _buffer != NULL ) {
    _buffer[0] = value;
    _buffer[1] = 0;
  }
}

String::String( const unsigned char value )
{
  _length = 1;
  getBuffer(1);
  if ( _buffer != NULL) {
    _buffer[0] = value;
    _buffer[1] = 0;
  }
}

String::String( const int value, const int base )
{
  char buf[33];   
  itoa((signed long)value, buf, base);
  getBuffer( _length = strlen(buf) );
  if ( _buffer != NULL )
    strcpy( _buffer, buf );
}

String::String( const unsigned int value, const int base )
{
  char buf[33];   
  ultoa((unsigned long)value, buf, base);
  getBuffer( _length = strlen(buf) );
  if ( _buffer != NULL )
    strcpy( _buffer, buf );
}

String::String( const long value, const int base )
{
  char buf[33];   
  ltoa(value, buf, base);
  getBuffer( _length = strlen(buf) );
  if ( _buffer != NULL )
    strcpy( _buffer, buf );
}




// floatToString.h
//
// Tim Hirzel
// tim@growdown.com
// March 2008
// float to string
// 
// If you don't save this as a .h, you will want to remove the default arguments 
//     uncomment this first line, and swap it for the next.  I don't think keyword arguments compile in .pde files

//char * floatToString(char * outstr, float value, int places, int minwidth=, bool rightjustify) {
char * floatToString(char * outstr, float value, int places, int minwidth=0, bool rightjustify=false) {
    // this is used to write a float value to string, outstr.  oustr is also the return value.
    int digit;
    float tens = 0.1;
    int tenscount = 0;
    int i;
    float tempfloat = value;
    int c = 0;
    int charcount = 1;
    int extra = 0;
    // make sure we round properly. this could use pow from <math.h>, but doesn't seem worth the import
    // if this rounding step isn't here, the value  54.321 prints as 54.3209

    // calculate rounding term d:   0.5/pow(10,places)  
    float d = 0.5;
    if (value < 0)
        d *= -1.0;
    // divide by ten for each decimal place
    for (i = 0; i < places; i++)
        d/= 10.0;    
    // this small addition, combined with truncation will round our values properly 
    tempfloat +=  d;

    // first get value tens to be the large power of ten less than value    
    if (value < 0)
        tempfloat *= -1.0;
    while ((tens * 10.0) <= tempfloat) {
        tens *= 10.0;
        tenscount += 1;
    }

    if (tenscount > 0)
        charcount += tenscount;
    else
        charcount += 1;

    if (value < 0)
        charcount += 1;
    charcount += 1 + places;

    minwidth += 1; // both count the null final character
    if (minwidth > charcount){        
        extra = minwidth - charcount;
        charcount = minwidth;
    }

    if (extra > 0 and rightjustify) {
        for (int i = 0; i< extra; i++) {
            outstr[c++] = ' ';
        }
    }

    // write out the negative if needed
    if (value < 0)
        outstr[c++] = '-';

    if (tenscount == 0) 
        outstr[c++] = '0';

    for (i=0; i< tenscount; i++) {
        digit = (int) (tempfloat/tens);
        itoa(digit, &outstr[c++], 10);
        tempfloat = tempfloat - ((float)digit * tens);
        tens /= 10.0;
    }

    // if no places after decimal, stop now and return

    // otherwise, write the point and continue on
    if (places > 0)
    outstr[c++] = '.';


    // now write out each decimal place by shifting digits one by one into the ones place and writing the truncated value
    for (i = 0; i < places; i++) {
        tempfloat *= 10.0; 
        digit = (int) tempfloat;
        itoa(digit, &outstr[c++], 10);
        // once written, subtract off that digit
        tempfloat = tempfloat - (float) digit; 
    }
    if (extra > 0 and not rightjustify) {
        for (int i = 0; i< extra; i++) {
            outstr[c++] = ' ';
        }
    }


    outstr[c++] = '\0';
    return outstr;
}








    String::String(float value, int decimalPlaces)
    {
    	char buf[33];
    	floatToString(buf, value, decimalPlaces);
		getBuffer( _length = strlen(buf) );
		if ( _buffer != NULL )
			strcpy( _buffer, buf );
    }

    String::String(double value, int decimalPlaces)
    {
    	
    	char buf[33];
    	floatToString(buf, value, decimalPlaces);
    		getBuffer( _length = strlen(buf) );
		if ( _buffer != NULL )
			strcpy( _buffer, buf );
	
    }




String::String( const unsigned long value, const int base )
{
  char buf[33];   
  ultoa(value, buf, 10);
  getBuffer( _length = strlen(buf) );
  if ( _buffer != NULL )
    strcpy( _buffer, buf );
}

char String::charAt( unsigned int loc ) const
{
  return operator[]( loc );
}

void String::setCharAt( unsigned int loc, const char aChar ) 
{
  if(_buffer == NULL) return;
  if(_length > loc) {
    _buffer[loc] = aChar;
  }
}

int String::compareTo( const String &s2 ) const
{
  return strcmp( _buffer, s2._buffer );
}

const String & String::concat( const String &s2 )
{
  return (*this) += s2;
}

const String & String::operator=( const String &rhs )
{
  if ( this == &rhs )
    return *this;

  if ( rhs._length > _length )
  {
    free(_buffer);
    getBuffer( rhs._length );
  }
  
  if ( _buffer != NULL ) {
    _length = rhs._length;
    strcpy( _buffer, rhs._buffer );
  }
  return *this;
}

//const String & String::operator+=( const char aChar )
//{
//  if ( _length == _capacity )
//    doubleBuffer();
//
//  _buffer[ _length++ ] = aChar;
//  _buffer[ _length ] = '\0';
//  return *this;
//}

const String & String::operator+=( const String &other )
{
  _length += other._length;
  if ( _length > _capacity )
  {
    char *temp = (char *)realloc(_buffer, _length + 1);
    if ( temp != NULL ) {
      _buffer = temp;
      _capacity = _length;
    } else {
      _length -= other._length;
      return *this;
    }
  }
  strcat( _buffer, other._buffer );
  return *this;
}


int String::operator==( const String &rhs ) const
{
  return ( _length == rhs._length && strcmp( _buffer, rhs._buffer ) == 0 );
}

int String::operator!=( const String &rhs ) const
{
  return ( _length != rhs.length() || strcmp( _buffer, rhs._buffer ) != 0 );
}

int String::operator<( const String &rhs ) const
{
  return strcmp( _buffer, rhs._buffer ) < 0;
}

int String::operator>( const String &rhs ) const
{
  return strcmp( _buffer, rhs._buffer ) > 0;
}

int String::operator<=( const String &rhs ) const
{
  return strcmp( _buffer, rhs._buffer ) <= 0;
}

int String::operator>=( const String & rhs ) const
{
  return strcmp( _buffer, rhs._buffer ) >= 0;
}

char & String::operator[]( unsigned int index )
{
  static char dummy_writable_char;
  if (index >= _length || !_buffer) {
    dummy_writable_char = 0;
    return dummy_writable_char;
  }
  return _buffer[ index ];
}

char String::operator[]( unsigned int index ) const
{
  // need to check for valid index, to do later
  return _buffer[ index ];
}

boolean String::endsWith( const String &s2 ) const
{
  if ( _length < s2._length )
    return 0;

  return strcmp( &_buffer[ _length - s2._length], s2._buffer ) == 0;
}

boolean String::equals( const String &s2 ) const
{
  return ( _length == s2._length && strcmp( _buffer,s2._buffer ) == 0 );
}

boolean String::equalsIgnoreCase( const String &s2 ) const
{
  if ( this == &s2 )
    return true; //1;
  else if ( _length != s2._length )
    return false; //0;

  return strcmp(toLowerCase()._buffer, s2.toLowerCase()._buffer) == 0;
}

String String::replace( char findChar, char replaceChar )
{
  if ( _buffer == NULL ) return *this;
  String theReturn = _buffer;
  char* temp = theReturn._buffer;
  while( (temp = strchr( temp, findChar )) != 0 )
    *temp = replaceChar;

  return theReturn;
}

String String::replace( const String& match, const String& replace )
{
  if ( _buffer == NULL ) return *this;
  String temp = _buffer, newString;

  int loc;
  while ( (loc = temp.indexOf( match )) != -1 )
  {
    newString += temp.substring( 0, loc );
    newString += replace;
    temp = temp.substring( loc + match._length );
  }
  newString += temp;  
  return newString;
}

int String::indexOf( char temp ) const
{
  return indexOf( temp, 0 );
}

int String::indexOf( char ch, unsigned int fromIndex ) const
{
  if ( fromIndex >= _length )
    return -1;

  const char* temp = strchr( &_buffer[fromIndex], ch );
  if ( temp == NULL )
    return -1;

  return temp - _buffer;
}

int String::indexOf( const String &s2 ) const
{
  return indexOf( s2, 0 );
}

int String::indexOf( const String &s2, unsigned int fromIndex ) const
{
  if ( fromIndex >= _length )
    return -1;

  const char *theFind = strstr( &_buffer[ fromIndex ], s2._buffer );

  if ( theFind == NULL )
    return -1;

  return theFind - _buffer; // pointer subtraction
}

int String::lastIndexOf( char theChar ) const
{
  return lastIndexOf( theChar, _length - 1 );
}

int String::lastIndexOf( char ch, unsigned int fromIndex ) const
{
  if ( fromIndex >= _length )
    return -1;

  char tempchar = _buffer[fromIndex + 1];
  _buffer[fromIndex + 1] = '\0';
  char* temp = strrchr( _buffer, ch );
  _buffer[fromIndex + 1] = tempchar;

  if ( temp == NULL )
    return -1;

  return temp - _buffer;
}

int String::lastIndexOf( const String &s2 ) const
{
  return lastIndexOf( s2, _length - s2._length );
}

int String::lastIndexOf( const String &s2, unsigned int fromIndex ) const
{
  // check for empty strings
  if ( s2._length == 0 || s2._length - 1 > fromIndex || fromIndex >= _length )
    return -1;

  // matching first character
  char temp = s2[ 0 ];

  for ( int i = fromIndex; i >= 0; i-- )
  {
    if ( _buffer[ i ] == temp && (*this).substring( i, i + s2._length ).equals( s2 ) )
    return i;
  }
  return -1;
}

boolean String::startsWith( const String &s2 ) const
{
  if ( _length < s2._length )
    return 0;

  return startsWith( s2, 0 );
}

boolean String::startsWith( const String &s2, unsigned int offset ) const
{
  if ( offset > _length - s2._length )
    return 0;

  return strncmp( &_buffer[offset], s2._buffer, s2._length ) == 0;
}

String String::substring( unsigned int left ) const
{
  return substring( left, _length );
}

String String::substring( unsigned int left, unsigned int right ) const
{
  if ( left > right )
  {
    int temp = right;
    right = left;
    left = temp;
  }

  if ( right > _length )
  {
    right = _length;
  } 

  char temp = _buffer[ right ];  // save the replaced character
  _buffer[ right ] = '\0';	
  String outPut = ( _buffer + left );  // pointer arithmetic
  _buffer[ right ] = temp;  //restore character
  return outPut;
}

String String::toLowerCase() const
{
  String temp = _buffer;

  for ( unsigned int i = 0; i < _length; i++ )
    temp._buffer[ i ] = (char)tolower( temp._buffer[ i ] );
  return temp;
}

String String::toUpperCase() const
{
  String temp = _buffer;

  for ( unsigned int i = 0; i < _length; i++ )
    temp._buffer[ i ] = (char)toupper( temp._buffer[ i ] );
  return temp;
}

String String::trim() const
{
  if ( _buffer == NULL ) return *this;
  String temp = _buffer;
  unsigned int i,j;

  for ( i = 0; i < _length; i++ )
  {
    if ( !isspace(_buffer[i]) )
      break;
  }

  for ( j = temp._length - 1; j > i; j-- )
  {
    if ( !isspace(_buffer[j]) )
      break;
  }

  return temp.substring( i, j + 1);
}

void String::getBytes(unsigned char *buf, unsigned int bufsize)
{
  if (!bufsize || !buf) return;
  unsigned int len = bufsize - 1;
  if (len > _length) len = _length;
  strncpy((char *)buf, _buffer, len);
  buf[len] = 0;
}

void String::toCharArray(char *buf, unsigned int bufsize)
{
  if (!bufsize || !buf) return;
  unsigned int len = bufsize - 1;
  if (len > _length) len = _length;
  strncpy(buf, _buffer, len);
  buf[len] = 0;
}


long String::toInt() {
  return atol(_buffer);
}
