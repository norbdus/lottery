class CreateConcursos < ActiveRecord::Migration[5.2]
  def change
    create_table :concursos do |t|
      t.integer :concurso
      t.date :data_sorteio
      t.integer :bola1
      t.integer :bola2
      t.integer :bola3
      t.integer :bola4
      t.integer :bola5
      t.integer :bola6
      t.integer :bola7
      t.integer :bola8
      t.integer :bola9
      t.integer :bola10
      t.integer :bola11
      t.integer :bola12
      t.integer :bola13
      t.integer :bola14
      t.integer :bola15
      t.integer :arrecadacao_total
      t.integer :ganhadores_15_numeros
      t.integer :ganhadores_14_numeros
      t.integer :ganhadores_13_numeros
      t.integer :ganhadores_12_numeros
      t.integer :ganhadores_11_numeros
      t.decimal :valor_rateio_15_numeros, precision: 15, scale: 2
      t.decimal :valor_rateio_14_numeros, precision: 15, scale: 2
      t.decimal :valor_rateio_13_numeros, precision: 15, scale: 2
      t.decimal :valor_rateio_12_numeros, precision: 15, scale: 2
      t.decimal :valor_rateio_11_numeros, precision: 15, scale: 2
      t.decimal :acumulado_15_numeros, precision: 15, scale: 2
      t.decimal :estimativa_premio, precision: 15, scale: 2
      t.decimal :valor_acumulado_especial, precision: 15, scale: 2

      t.timestamps
    end
  end
end
