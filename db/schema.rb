# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_31_000748) do

  create_table "concursos", force: :cascade do |t|
    t.integer "concurso"
    t.date "data_sorteio"
    t.integer "bola1"
    t.integer "bola2"
    t.integer "bola3"
    t.integer "bola4"
    t.integer "bola5"
    t.integer "bola6"
    t.integer "bola7"
    t.integer "bola8"
    t.integer "bola9"
    t.integer "bola10"
    t.integer "bola11"
    t.integer "bola12"
    t.integer "bola13"
    t.integer "bola14"
    t.integer "bola15"
    t.integer "arrecadacao_total"
    t.integer "ganhadores_15_numeros"
    t.integer "ganhadores_14_numeros"
    t.integer "ganhadores_13_numeros"
    t.integer "ganhadores_12_numeros"
    t.integer "ganhadores_11_numeros"
    t.decimal "valor_rateio_15_numeros", precision: 15, scale: 2
    t.decimal "valor_rateio_14_numeros", precision: 15, scale: 2
    t.decimal "valor_rateio_13_numeros", precision: 15, scale: 2
    t.decimal "valor_rateio_12_numeros", precision: 15, scale: 2
    t.decimal "valor_rateio_11_numeros", precision: 15, scale: 2
    t.decimal "acumulado_15_numeros", precision: 15, scale: 2
    t.decimal "estimativa_premio", precision: 15, scale: 2
    t.decimal "valor_acumulado_especial", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
