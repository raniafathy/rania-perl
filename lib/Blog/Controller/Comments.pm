package Blog::Controller::Comments;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }
#####################################################
sub comment_list :Local {
my ($self, $c) = @_;
$c->stash(comments => [$c->model('DB::Comment')->all()]);
$c->stash(template => 'comments/comment_list.tt');
}
#######################################################################################
sub base :Chained('/') :PathPart('comments') :CaptureArgs(0) {
    my ($self, $c) = @_;
 
    # Store the ResultSet in stash so it's available for other methods
    $c->stash(resultset => $c->model('DB::Comment'));
 
    # Print a message to the debug log
    $c->log->debug('*** INSIDE BASE METHOD ***');
}
###########################################################################################
sub comment_form :Chained('base') :PathPart('comment_form') :Args(0) {
    my ($self, $c) = @_;
 
    # Set the TT template to use
    $c->stash(template => 'comments/comment_form.tt');
}
########################################################################################################
sub form_create_do :Chained('base') :PathPart('form_create_do') :Args(0) {
    my ($self, $c) = @_;
 
    # Retrieve the values from the form
    my $commenter     = $c->request->params->{commenter} ;
    my $body    = $c->request->params->{body} ;
 
    # Create the book
    my $comment = $c->model('DB::Article')->create({
            commenter   => $commenter,
            body  => $body,
       
        });
    # Handle relationship with author
    #$book->add_to_book_authors({author_id => $author_id});
    # Note: Above is a shortcut for this:
    # $book->create_related('book_authors', {author_id => $author_id});
 
    # Store new model object in stash and set template
    #$c->stash(article     => $article,
             # template => 'articles/article_list.tt');
$c->stash(comment=>$c->stash->{object},template => 'comments/show.tt');

}
###########################################################################################
sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of book to delete
    my ($self, $c, $id) = @_;
 
    # Find the book object and store it in the stash
    $c->stash(object => $c->stash->{resultset}->find($id));
 
    # Make sure the lookup was successful.  You would probably
    # want to do something like this in a real app:
    #   $c->detach('/error_404') if !$c->stash->{object};
    die "Book $id not found!" if !$c->stash->{object};
 
    # Print a message to the debug log
    $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
}
############################################################################################
sub delete :Chained('object') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;
 
    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash->{object}->delete;
 
    # Set a status message to be displayed at the top of the view
    $c->stash->{status_msg} = "User deleted.";
 
    # Redirect the user back to the list page.  Note the use
    # of $self->action_for as earlier in this section (BasicCRUD)
    $c->response->redirect($c->uri_for($self->action_for('article_list')));
}
#################################################################################################
sub edit :Chained('object') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;
 
    # Set the TT template to use
    $c->stash( comment=>$c->stash->{object},template => 'comments/comment_edit.tt');
}
###################################################################################################
sub update :Chained('object') :PathPart('update') :Args(0) {
    my ($self, $c) = @_;
 
    # Retrieve the values from the form
     my $commenter     = $c->request->params->{commenter} ;
    my $body    = $c->request->params->{body} ;
 
    # Create the book
    $c->stash->{object}->update({
            commenter   => $commenter,
            body  => $body,
        });
    $c->response->redirect($c->uri_for($self->action_for('comment_list')));

}
##################################################################################################


=head1 NAME

Blog::Controller::Comments - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Comments in Comments.');
}



=encoding utf8

=head1 AUTHOR

rania fathy,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
