query="SELECT payment.id, payment.total, payment.eur_total, paid_date, order_id,
       address.country_id as CountryId,
       if(STRCMP(state.code, 0), state.code, null) as state,
       order_table.status as orderStatus,
       currency.code as userCurrency,
       order_table.total as orderTotal,
       order_table.items_total as orderItemsTotal,
       order_table.shipping_price as shippingPrice,
       IF (address.country_id in (\"USA\", \"CAN\", \"AUS\", \"MEX\", \"PRI\" ,\"AR\", \"BRA\", \"CHL\", \"COL\",
                                 \"CRI\", \"DOM\", \"ECU\", \"NZL\", \"PAN\", \"PER\", \"PRI\", \"PRY\", \"SGP\",
                                 \"URY\"), \"INC\", \"SL\") as MumaOwner,
       (select count(order_item.id) from order_item where order_id = order_table.id ) as books,
       order_table.eur_shipping_price as orderShippingTotal,
       order_table.eur_items_total as eurOrderItemTotal,
       order_table.eur_total as eurOrderTotal,
       order_table.voucher_code as voucherCode,
       (select voucher.discount from voucher where voucher.code = order_table.voucher_code ) as voucherDiscound,
       (select GROUP_CONCAT(\"PO-\", print_order.id ORDER BY print_order.id ASC SEPARATOR ', ') from print_order where print_order.order_id = order_table.id) as totalPrintOrders,
       (select GROUP_CONCAT(tracking_id ORDER BY shipment.tracking_id ASC SEPARATOR ', ') from shipment where shipment.order_id = payment.order_id ) as trackingId,
       (select GROUP_CONCAT(order_note.text ORDER BY order_note.text DESC SEPARATOR ', ') from order_note where parent_order_id = payment.order_id) as noteId,
       payment.transaction_id as claveStripePaypal,
       (select pay_method.method from pay_method where pay_method.id = payment.method_id) as paidMethod,
       (select GROUP_CONCAT(refund.transaction_id order by refund.transaction_id ASC SEPARATOR ', ') from refund where refund.payment_id = payment.id) as refund,
       (select GROUP_CONCAT(invoice.id ORDER BY invoice.id ASC SEPARATOR ', ') from invoice where invoice.order_id = payment.order_id) idFacturas
    FROM payment
    inner join order_table on order_table.id = order_id
    inner join address on address.id = order_table.address_id
    inner join currency on currency.id = payment.currency_id
    inner join state on state.id = address.state_id"

/datos/carga/CTR/bin/external2.sh 33 "$query"