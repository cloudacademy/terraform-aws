package com.cloudacademy.stocks.service;

import java.util.List;

import com.cloudacademy.stocks.entity.Stock;

public interface StockService {
    Stock createStock(Stock stock);

    List<Stock> getAllStocks();
}
