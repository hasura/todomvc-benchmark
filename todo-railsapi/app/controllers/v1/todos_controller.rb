module V1
  class TodosController < ApplicationController

    def select
      @todos = current_user.todos.all

      render json: @todos
    end

    def insert
      @todo = current_user.todos.build(todo_params)
      @todo.save!

      render json: @todo
    end

    def update
      @todo = current_user.todos.find(params[:id])
      @todo.update!(todo_params)

      render json: @todo
    end

    def delete_completed
      @todos_for_destruction = current_user.todos.completed.all
      @todos_for_destruction.destroy_all

      render json: { message: "Destroyed all completed todos" }
    end

    def delete
      @todo = current_user.todos.find(params[:id])
      @todo.destroy

      render json: { message: "Deleted todo: #{params[:id]}" }
    end

    def toggle_all
      @todos = current_user.todos.update_all(completed: 't')

      render json: { message: "Deleted todo: #{params[:id]}" }
    end

  private

    def todo_params
      params.permit(:title, :completed)
    end

  end
  
end
