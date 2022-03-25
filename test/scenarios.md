1) presale checks - v1
   [x] should mint xWaifus
   [x] should fail if user wont pay enough fee

2) presale checks - v2
   [x] should fail if user mints more than MAX_PER_WALLET
   [x] should fail if user wont pay the fee
   [x] should fail if user mints more than PRESALE_TOTAL_SUPPLY
   [x] should fail if user mints when presale isn't allowed

3) public sale checks - v1
   [x] should mint xWaifus
   [x] should mint multiple xWaifus
   [x] should fail if user wont pay enough fee

4) public sale checks - v2
   [ ] should fail if user mints more than TOTAL_SUPPLY
   [ ] should fail if user wont pay the fee
   [ ] should fail if user mints when public sale isn't allowed

5) Situational checks 
   [ ] case where presale didn't sold out so we move to public
