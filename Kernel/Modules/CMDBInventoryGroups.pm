# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::CMDBInventoryGroups;

use strict;
use warnings;
use Data::Dumper;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # build output
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    
    my %mydata;
    $mydata{'function'}="visu_groups";
    $mydata{'title'}="CMDB Groups";
    $Output .= $LayoutObject->Output(
        TemplateFile => 'CMDB',
        Data         => \%mydata,
    );
    $Output .= $LayoutObject->Footer();

    return $Output;
}

1;
