# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

=c
Agent Assignment Master
----------------------------------------------------------------#
# Functionality of the Module..					#
----------------------------------------------------------------#
1. Query is selected and based on that sub-query is populated.  #
2. Sub Query is selected.					#
3. User is selected from dropdown and saved.			#
----------------------------------------------------------------#
Note :- All the fields are mandatory.				#
#---------------------------------------------------------------#
=cut

package Kernel::Modules::AgentAssignmentMaster;

use strict;
use warnings;
use Data::Dumper;
use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{CacheType} = 'AgentAssignmentMaster';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    # ------------------------------------------------------------ #
    # change
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Change' ) {
        my $ID = $ParamObject->GetParam( Param => 'ID' ) || '';
        my %Data = $Self->GetData(ID => $ID);
        if ( !%Data ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Need Data to Edit!'),
            );
        }
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Self->_Edit(
            Action => 'Change',
            %Data,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAssignmentMaster',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # change action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $Note = '';
        my ( %GetParam, %Errors );
        for my $Parameter (qw(ID Query SubQuery AgentID ValidID)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        # check needed data
        for my $Needed (qw(ID Query SubQuery AgentID ValidID)) {
            if ( !$GetParam{$Needed} ) {
                $Errors{ $Needed . 'Invalid' } = 'ServerError';
            }
        }

        my %Data = $Self->GetData( ID => $GetParam{ID} );
        if ( !%Data ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('No Record Exist!'),
            );
        }

        # check if a type exists with this name
        my $RecordExists = $Self->RecordExistsCheck(
            Query    => $GetParam{Query},
	    SubQuery => $GetParam{SubQuery},
	    AgentID  => $GetParam{AgentID},
	    ValidID  => $GetParam{ValidID},
	    ID       => $GetParam{ID},
        );

	# If Record Exists, throw an error.
	if ($RecordExists) {
            $Errors{QueryExists} = 1;
#            $Errors{'QueryInvalid'} = 'ServerError';

            $Errors{SubQueryExists} = 1;
#            $Errors{'SubQueryInvalid'} = 'ServerError';

            $Errors{AgentIDExists} = 1;
#            $Errors{'AgentIDInvalid'} = 'ServerError';

            $Errors{ValidIDExists} = 1;
#            $Errors{'ValidIDInvalid'} = 'ServerError';

        }


        # if no errors occurred
        if ( !%Errors ) {

            # update type
            my $Update = $Self->RecordUpdate(
                %GetParam,
            );
            if ($Update) {
                $Self->_Overview();
                my $Output = $LayoutObject->Header();
                $Output .= $LayoutObject->NavigationBar();
                $Output .= $LayoutObject->Notify( Info => Translatable('Agent Assignment Updated Successfully!') );
                $Output .= $LayoutObject->Output(
                    TemplateFile => 'AgentAssignmentMaster',
                    Data         => \%Param,
                );
                $Output .= $LayoutObject->Footer();
                return $Output;
            }
        }

        # something has gone wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Notify( Priority => 'Error' );
        $Self->_Edit(
            Action => 'Change',
            Errors => \%Errors,
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAssignmentMaster',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # add
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Add' ) {
        my %GetParam = ();
        $GetParam{ID} = $ParamObject->GetParam( Param => 'ID' );

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        $Self->_Edit(
            Action => 'Add',
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAssignmentMaster',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # add action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $Note = '';
        my ( %GetParam, %Errors );
	for my $Parameter (qw(Query SubQuery AgentID ValidID)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        # check needed data
        for my $Needed (qw(Query SubQuery AgentID ValidID)) {
            if ( !$GetParam{$Needed} ) {
                $Errors{ $Needed . 'Invalid' } = 'ServerError';
            }
        }

        # check if this row exists in the system.
        my $RecordExists = $Self->RecordExistsCheck(
            Query     => $GetParam{Query},
            SubQuery  => $GetParam{SubQuery},
            AgentID   => $GetParam{AgentID},
	    ValidID   => $GetParam{ValidID},
	    ID	      => $GetParam{ID},
        );

        # If record already exists
	if ($RecordExists) {
            $Errors{QueryExists} = 1;
#            $Errors{'QueryInvalid'} = 'ServerError';

            $Errors{SubQueryExists} = 1;
#            $Errors{'SubQueryInvalid'} = 'ServerError';

            $Errors{AgentIDExists} = 1;
#            $Errors{'AgentIDInvalid'} = 'ServerError';

            $Errors{ValidIDExists} = 1;
#            $Errors{'ValidIDInvalid'} = 'ServerError';

        }

        # if no errors occurred
        if ( !%Errors ) {

            # add type
            my $NewRecord = $Self->RecordAdd(
                %GetParam,
            );
            if ($NewRecord) {
                $Self->_Overview();
                my $Output = $LayoutObject->Header();
                $Output .= $LayoutObject->NavigationBar();
                $Output .= $LayoutObject->Notify( Info => Translatable('Agent Assigned!') );
                $Output .= $LayoutObject->Output(
                    TemplateFile => 'AgentAssignmentMaster',
                    Data         => \%Param,
                );
                $Output .= $LayoutObject->Footer();
                return $Output;
            }
        }

        # something has gone wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Notify( Priority => 'Error' );
        $Self->_Edit(
            Action => 'Add',
            Errors => \%Errors,
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAssignmentMaster',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }
    #-------------------------------------------------------------
    # GetSubQueries on ajax call
    #-------------------------------------------------------------
    elsif ( $Self->{Subaction} eq 'GetSubQuery' ) {

	my $QueryID = $ParamObject->GetParam( Param => 'QueryID' ) || '';
    	my %SubQueries = $Self->SubQueryList( QueryID => $QueryID );
    	my $JSON = $LayoutObject->JSONEncode(

           Data => \%SubQueries,
    	);
	
	return $LayoutObject->Attachment(
           ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
           Content     => $JSON,
           Type        => 'inline',
           NoCache     => 1,
       );

    }
    # ------------------------------------------------------------
    # overview
    # ------------------------------------------------------------
    else {

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # check if ticket type is enabled to use it here
        if ( !$Kernel::OM->Get('Kernel::Config')->Get('Ticket::Type') ) {
            $Output .= $LayoutObject->Notify(
                Priority => 'Error',
                Data     => $LayoutObject->{LanguageObject}->Translate( "Please activate %s first!", "Type" ),
                Link =>
                    $LayoutObject->{Baselink}
                    . 'Action=AdminSysConfig;Subaction=Edit;SysConfigGroup=Ticket;SysConfigSubGroup=Core::Ticket#Ticket::Type',
            );
        }

        $Self->_Overview();
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAssignmentMaster',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

}


#Add New Record

sub RecordAdd {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Do(
        SQL => 'INSERT INTO felicity_agent_assignment_master (mainquery, subquery, userid,valid_id)'
            . ' VALUES (?, ?, ?, ?)',
        Bind => [ \$Param{Query}, \$Param{SubQuery}, \$Param{AgentID}, \$Param{ValidID}],
    );

	
    # get new record id
    return if !$DBObject->Prepare(
        SQL => 'SELECT id FROM felicity_agent_assignment_master 
                WHERE mainquery = ? and subquery =? and userid =?',
        Bind => [ \$Param{Query}, \$Param{SubQuery}, \$Param{AgentID}],
    );

    # fetch the result
    my $ID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ID = $Row[0];
    }
    return if !$ID;
    return $ID;
}

#Update the record
sub RecordUpdate {
    my ( $Self, %Param ) = @_;
	return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'UPDATE felicity_agent_assignment_master SET mainquery = ?, subquery = ?, '
            . ' userid = ?, valid_id = ? WHERE id = ?',
        Bind => [
            \$Param{Query}, \$Param{SubQuery}, \$Param{AgentID}, \$Param{ValidID}, \$Param{ID},
        ],
    );

 return 1;
}


#Check Record already exist
sub RecordExistsCheck {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    
    return if !$DBObject->Prepare(
        SQL => 'SELECT id FROM felicity_agent_assignment_master 
		WHERE mainquery = ? AND subquery =? AND userid =? AND valid_id = ?',
        Bind => [ \$Param{Query}, \$Param{SubQuery}, \$Param{AgentID}, \$Param{ValidID} ],
    );

    #fetch the result
    my $Flag;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        if ( !$Param{ID} || $Param{ID} ne $Row[0] ) {
            $Flag = 1;
        }
    }
    if ($Flag) {
        return 1;
    }
    return 0;
}



# Fetch User list for display
sub UserList{
    my ( $Self, %Param ) = @_;
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $query = "SELECT id, CONCAT_WS(' ', first_name, last_name) as name from users WHERE valid_id=1";

    return if !$DBObject->Prepare(

        SQL => $query
    );

    my %Users;
    $Users{''} = '-';
    while( my @Row = $DBObject->FetchrowArray() ){

        $Users{ $Row[0] } = $Row[1];
    }

    return %Users;
}

#Fetch Query List

sub QueryList{
    my ( $Self, %Param ) = @_;
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $query = "SELECT parent_value, parent_value AS value FROM dependent_query_dropdown WHERE valid_id = 1";

    return if !$DBObject->Prepare(

        SQL => $query
    );

    my %Queries;
    $Queries{''} = '-';
    while( my @Row = $DBObject->FetchrowArray() ){

        $Queries{ $Row[0] } = $Row[1];
    }

    return %Queries;
}

#Fetch SubQuery List

sub SubQueryList{
    my ( $Self, %Param ) = @_;
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my %SubQueries;
    $SubQueries{''} = '-';

    if($Param{QueryID})
    {
	$DBObject->Prepare(
        SQL => 'SELECT child_value, child_value FROM dependent_query_dropdown WHERE parent_value = ? AND valid_id = 1',
	Bind => [ \$Param{QueryID} ]
    );
    while( my @Row = $DBObject->FetchrowArray() ){
        $SubQueries{ $Row[0] } = $Row[1];
    }
  }
    return %SubQueries;

}


#Get IDs
sub GetIDs{

    my ( $Self, %Param ) = @_;
    
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => "SELECT id, valid_id FROM felicity_agent_assignment_master"
    );

    my %Users;
    while( my @Row = $DBObject->FetchrowArray() ){

        $Users{ $Row[0] } = $Row[1];
    }

    return %Users;
}

sub _Edit {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' ); 
    
    # get Users lis
    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %UsersList = $Self->UserList();
    my %QueryList = $Self->QueryList();
    my %SubQueryList = $Self->SubQueryList('QueryID'=>$Param{Query});

    $Param{ValidOption} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $Param{ValidID} || 1,
        Class      => 'Modernize Validate_Required ' . ( $Param{Errors}->{'ValidIDInvalid'} || '' ),
    );

    $Param{AgentID} = $LayoutObject->BuildSelection(
        Data       => \%UsersList,
        Name       => 'AgentID',
        SelectedID => $Param{AgentID},
        Class      => 'Modernize Validate_Required ' . ( $Param{Errors}->{'AgentIDInvalid'} || '' ),
    );

    $Param{Query} = $LayoutObject->BuildSelection(
        Data       => \%QueryList,
        Name       => 'Query',
        SelectedID => $Param{Query},
        Class      => 'Modernize Validate_Required ' . ( $Param{Errors}->{'QueryInvalid'} || '' ),
    );


    $Param{SubQuery} = $LayoutObject->BuildSelection(
        Data       => \%SubQueryList,
        Name       => 'SubQuery',
        SelectedID => $Param{SubQuery},
        Class      => 'Modernize Validate_Required ' . ( $Param{Errors}->{'SubQueryInvalid'} || '' ),
    );

    $LayoutObject->Block(
        Name => 'OverviewUpdate',
        Data => {
            %Param,
            %{ $Param{Errors} },
        },
    );

    # shows header
    if ( $Param{Action} eq 'Change' ) {
        $LayoutObject->Block( Name => 'HeaderEdit' );
    }
    else {
        $LayoutObject->Block( Name => 'HeaderAdd' );
    }

    # shows appropriate message if error
    if ( defined $Param{Errors}->{AgentIDExists} && $Param{Errors}->{AgentIDExists} == 1 ) {
        $LayoutObject->Block( Name => 'ExistIDServerError' );
    }

    else {
        $LayoutObject->Block( Name => 'QueryServerError' );
    }

    return 1;

}

sub _Overview {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionAdd' );

    $LayoutObject->Block(
        Name => 'OverviewResult',
        Data => \%Param,
    );
	
    my %List = $Self->GetIDs();


    #if there are any types, they are shown
    if (%List) {

        my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
	my %UsersList = $Self->UserList();
        my %QueryList = $Self->QueryList();

        for my $RecordID ( sort { $List{$a} cmp $List{$b} } keys %List ) {
            my %Data = $Self->GetData(
                ID => $RecordID,
            );

	my %SubQueryList = $Self->SubQueryList('QueryID'=>$Data{Query});
	$Data{SubQuery}= $SubQueryList{$Data{SubQuery}};
	$Data{Query}= $QueryList{$Data{Query}};
	$Data{AgentID}= $UsersList{$Data{AgentID}};
	    $LayoutObject->Block(
                Name => 'OverviewResultRow',
                Data => {
                    Valid => $ValidList{ $Data{ValidID} },
                    %Data,
                },
            );
        }
    }

    #otherwise a no data found msg is displayed
    else {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
            Data => {},
        );
    }


    return 1;
}

#Single record based on ID
sub GetData {
    my ( $Self, %Param ) = @_;

        #Here ID must be passed
    if ( !$Param{ID}) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

        #Here get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $Sql = "SELECT id, mainquery, subquery, userid, valid_id FROM felicity_agent_assignment_master where id=?";

        #Here ask the database
    return if !$DBObject->Prepare(
	SQL => $Sql,
	Bind => [ \$Param{ID} ],
    );
        #Here fetch the result
    my %AgentAssignment;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        $AgentAssignment{ID}         = $Data[0];
        $AgentAssignment{Query}       = $Data[1];
        $AgentAssignment{SubQuery}    = $Data[2];
        $AgentAssignment{AgentID} = $Data[3];
	$AgentAssignment{AgentName} = $Data[3];
	$AgentAssignment{ValidID} = $Data[4];
    }

        #Here no data found
    if ( !%AgentAssignment ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "AgentAssignmentID '$Param{ID}' not found!",
        );
        return;
    }

    return %AgentAssignment;
}

1;
