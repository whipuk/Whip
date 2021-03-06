class VotesController < ApplicationController

	def create
		unless current_user.votes.where(bill_id: params[:bill_id]).any?
			@vote = current_user.votes.build
			@vote.bill_id = params[:bill_id]
			@vote.in_favor = params[:in_favor]
			@vote.comment = params[:comment]
		else
			@vote = current_user.votes.find_by(bill_id: params[:bill_id])
			@vote.in_favor = params[:in_favor]
			@vote.comment = params[:comment]
		end

		if @vote.save
			Resque.enqueue(NewVoteMessage, @vote.id)
			respond_to do |format|
	      		format.html {redirect_to :back}
	      		format.js { render :partial => 'vote_success.js.erb' }
	      	end
	  	else
	    	render 'static_pages/home'
	  	end
	    
	end

	def change_vote_comment
		@vote = Vote.find(params[:id])

		if @vote.update_attributes(vote_params)
			redirect_to :back
		else
			render 'static_pages/home'
		end
	end

	def my_votes

		unless user_signed_in?
			redirect_to root_path
		else
			@votes = current_user.votes.includes(:bill, :voteable)
		end
		
	end

	def upvote
		@vote = Vote.find(params[:id])
			@vote.comment_score += 1

		if @vote.save
			current_user.upvote!(@vote)
			respond_to do |format|
				format.html {redirect_to :back}
				format.js {render :partial => 'upvote_success.js.erb', :locals => { :vote => @vote }}
			end
		else
			redirect_to :back
		end

	end

	def update
		@vote = Vote.find(params[:id])

		
		if @vote.update_attributes(vote_params)
			redirect_to :back
		else
			redirect_to :back
		end

	end

	private

	  def vote_params
	  	params.require(:vote).permit(:comment, :in_favor)
	  end

end