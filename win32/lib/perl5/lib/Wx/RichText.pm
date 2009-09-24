#############################################################################
## Name:        ext/richtext/lib/Wx/RichText.pm
## Purpose:     Wx::RichTextCtrl and related classes
## Author:      Mattia Barbon
## Modified by:
## Created:     05/11/2006
## RCS-ID:      $Id: RichText.pm 2310 2007-12-31 00:31:49Z mbarbon $
## Copyright:   (c) 2006-2007 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package Wx::RichText;

use strict;

our $VERSION = '0.01';

Wx::load_dll( 'adv' );
Wx::load_dll( 'html' );
Wx::load_dll( 'xml' );
Wx::load_dll( 'richtext' );
Wx::wx_boot( 'Wx::RichText', $VERSION );

SetEvents();

#
# properly setup inheritance tree
#

no strict;

package Wx::RichTextCtrl;    @ISA = qw(Wx::TextCtrl);
package Wx::TextAttrEx;      @ISA = qw(Wx::TextAttr);
package Wx::RichTextEvent;   @ISA = qw(Wx::NotifyEvent);
package Wx::RichTextStyleDefinition;
package Wx::RichTextCharacterStyleDefinition; @ISA = qw(Wx::RichTextStyleDefinition);
package Wx::RichTextParagraphStyleDefinition; @ISA = qw(Wx::RichTextStyleDefinition);
package Wx::RichTextListStyleDefinition; @ISA = qw(Wx::RichTextParagraphStyleDefinition);
package Wx::RichTextStyleListCtrl; @ISA = qw(Wx::Control);
package Wx::HtmlListBox;     @ISA = qw(Wx::VListBox);
package Wx::RichTextStyleListBox; @ISA = qw(Wx::HtmlListBox);
package Wx::RichTextStyleComboCtrl; @ISA = qw(Wx::ComboCtrl);
package Wx::RichTextFormattingDialog; @ISA = qw(Wx::PropertySheetDialog);
package Wx::RichTextXMLHandler; @ISA = qw(Wx::RichTextFileHandler);
package Wx::RichTextHTMLHandler; @ISA = qw(Wx::RichTextFileHandler);
package Wx::RichTextObject;
package Wx::RichTextCompositeObject; @ISA = qw(Wx::RichTextObject);
package Wx::RichTextBox;     @ISA = qw(Wx::RichTextCompositeObject);
package Wx::RichTextParagraphLayoutBox; @ISA = qw(Wx::RichTextBox);
package Wx::RichTextBuffer;  @ISA = qw(Wx::RichTextParagraphLayoutBox);
package Wx::SymbolPickerDialog; @ISA = qw(Wx::Dialog);
package Wx::RichTextStyleOrganiserDialog; @ISA = qw(Wx::Dialog);

1;
