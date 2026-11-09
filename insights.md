# SokoMart Sales Analysis: Key Findings and Recommendations

By Wangai ([@SirWangai](https://github.com/SirWangai))
November 2026

For this project I used SQL to work through the sales records of SokoMart Kenya (Duka Smart Electronics): 800 orders from 150 customers across 10 Kenyan towns and cities. I looked at who buys, how often, what they buy, what the company makes on each category, and which customers are worth the most over time.

Three things stood out. M-Pesa collects most of the money. The products that bring in the most revenue earn the least on each sale. And too many expensive orders get cancelled after the stock has already been set aside.

## M-Pesa is how this business gets paid

More than 65% of finalized orders are paid through M-Pesa. Bank transfers and cards mostly show up on business orders above KSh 100,000, while cash is small and shrinking, at under 15%.

With that much money moving through one channel, a slow or failed STK push can cost the sale at checkout. I'd put a formal service agreement in place with Safaricom for the Daraja API, send the STK push automatically at checkout, and reconcile reversals straight away so fewer customers give up halfway. (Q10, Q13)

## Expensive orders are the ones falling through

About 13.75% of all orders are cancelled, and the cancellations lean toward the big-ticket items, especially the Samsung 55" Smart TV (KSh 79,999) and the iPhone 13 (KSh 89,999).

Each of those cancellations holds stock that someone else could have bought, and it makes the out-of-stock numbers look worse than they are. Two fixes would help: hold items for 15 minutes at checkout instead of indefinitely, and ask for SMS or multi-factor verification before logging any order above KSh 50,000. (Q20)

## Nairobi leads, but other towns have room to grow

Nairobi brings in the largest share of completed revenue, followed by Mombasa and Nakuru. Meru, Machakos and Kisumu are more interesting. Plenty of customers have registered there, but they spend much less per order.

Outside Nairobi and the Coast, branches are mostly acting as pickup points for accessories rather than places where people buy expensive items. I'd set up small fulfillment hubs in Nakuru and Eldoret and subsidize regional delivery on orders above KSh 20,000 to encourage bigger purchases inland. (Q17, Q25)

## The biggest sellers aren't the most profitable

Mobile phones and electronics make up over 60% of revenue, but their gross margins sit between 11.5% and 14.8%. Accessories like Anker chargers, Oraimo earbuds and Logitech mice, along with some computing peripherals, earn between 48.0% and 53.5%.

Selling more phones on its own adds a lot of turnover and very little profit. The fix is to make bundling routine, both in store and online, so every phone sale comes with an offer on a discounted 20W Anker charger, a screen protector or a case. (Q33, Q46)

## A small group of customers matters a lot

The top 10% of customers account for an outsized share of profit. They tend to buy computing products like HP 250 G9 laptops and Lenovo IdeaPads, along with premium appliances like Hotpoint double-door refrigerators.

I also compared average spending by customer segment, adding up each customer's completed order revenue and then averaging it across the active buyers in each segment. VIP customers spend the most on average, which supports the case that keeping them through dedicated loyalty benefits delivers more lifetime value than broader acquisition campaigns.

Losing one of these customers hurts as much as losing dozens of people who only buy accessories, so they deserve their own service: a named account manager they can phone, hardware replacement guaranteed within 24 hours, and Net-30 invoicing for verified corporate clients. (Q24, Q27, Q28, Q45)

## Sales peak at the end of the year, then drop

Revenue climbs quickly going into the fourth quarter and peaks in November and December. It then falls by more than 30% in January and February.

Running out of stock in the Q4 rush means sales that don't come back, and overstocking in January ties up cash. Supplier container orders should be locked in by mid-October. In January and February, promotions could shift to student computing bundles and installment plans (Lipa Mdogo Mdogo) to keep cash moving. (Q31, Q38, Q40)

## How each category compares

| Category | Revenue | Margin | What drives it | What to do |
| :--- | :--- | :--- | :--- | :--- |
| Mobile phones | Very high | Low (~12%) | Volume, and it brings people in | Add an accessory offer to every handset sale |
| Electronics (TVs, audio) | High | Moderate (~16%) | Home entertainment upgrades | Pair soundbars with 55" TVs |
| Computing | High | Healthy (~18–22%) | Businesses, remote workers, students | Offer extended warranties and peripheral bundles |
| Home appliances | Moderate | Balanced (~20%) | Everyday household need | Offer structured installment plans |
| Accessories | Moderate | Exceptional (>50%) | Impulse buys and add-ons | Display at checkout and run multi-buy discounts |

## Top Priority Recommendation

I'd start with accessory cross-selling. Flagship products bring in the revenue, but there isn't much left once marketing, logistics and payment fees come out.

Both the POS terminals and the branch counters should prompt staff to offer a matching accessory bundle before they can complete a sale. If accessories get added to 25% of smartphone and TV sales, I estimate overall gross margin would rise by 3.2 to 4.5 percentage points, with no extra spending on ads or customer acquisition.

## Methodology and Metric Definitions

Revenue, margin and customer lifetime value only include orders where `order_status = 'Completed'`, so cancelled and pending orders don't distort the numbers.

Net revenue is the sum of quantity × unit price × (1 − discount ÷ 100) across order lines.

Gross profit is net revenue minus the sum of quantity × cost price.
