class Ability
  include CanCan::Ability
  def initialize account
    if account&.is_admin?
      can :manage, :all
      cannot :manage, Cart
      cannot %i(create update), Comment
      cannot :manage, Favourite
      cannot %i(create update), Rating
    else
      define_account_permissions(account)
      cannot :access, :admin
    end
  end

  private

  def define_account_permissions account
    can :read,
        [Book, Author, Rating, Category, BookSeries, BookInventory]
    can :create, Account
    can %i(reply read), Comment

    return unless account

    if account.user
      define_user_permissions(account.user)
    else
      can :create, User, account_id: account.id
    end
  end

  def define_user_permissions user
    user_id = user.id

    can(:manage, User, id: user_id)
    can(:manage, Cart, user_id:)
    can(:manage, Comment)
    can(:manage, Favourite, user_id:)
    can(%i(create update), Rating, user_id:)
    can(:manage, Request, user_id:)
    can(:manage, BorrowBook, user_id:)
  end
end
