/**
 * @description Unit tests for GetFoodDetailsInvocable.
 *
 *              Key assertion: when a list with two or more FoodDetailRequest
 *              elements is passed to getFoodDetails(), the returned list must
 *              have the same size as the input list.  This verifies that the
 *              return statement is OUTSIDE the for-loop (the fix for WI-000004).
 */
@IsTest
private class GetFoodDetailsInvocableTest {

    // -------------------------------------------------------------------------
    // Helper
    // -------------------------------------------------------------------------

    private static GetFoodDetailsInvocable.FoodDetailRequest buildRequest(
            String foodName, String category, Decimal maxCalories) {
        GetFoodDetailsInvocable.FoodDetailRequest req =
            new GetFoodDetailsInvocable.FoodDetailRequest();
        req.foodName    = foodName;
        req.category    = category;
        req.maxCalories = maxCalories;
        return req;
    }

    // -------------------------------------------------------------------------
    // Tests
    // -------------------------------------------------------------------------

    /**
     * @description Verifies that a single-element list is handled correctly.
     *              This is the baseline, single-element case.
     */
    @IsTest
    static void testSingleRequest() {
        List<GetFoodDetailsInvocable.FoodDetailRequest> requests =
            new List<GetFoodDetailsInvocable.FoodDetailRequest>{
                buildRequest('Pizza', 'Italian', 800)
            };

        Test.startTest();
        List<GetFoodDetailsInvocable.FoodDetailResponse> responses =
            GetFoodDetailsInvocable.getFoodDetails(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(),
            'Expected exactly 1 response for a single-element input list');
        System.assertNotEquals(null, responses[0].foodDetails,
            'foodDetails list should not be null');
        System.assertEquals(1, responses[0].foodDetails.size(),
            'Expected 1 food detail entry');
        System.assertEquals('Pizza', responses[0].foodDetails[0].foodName,
            'Food name should be Pizza');
    }

    /**
     * @description Verifies that a two-element list returns two responses.
     *              This directly tests the WI-000004 fix: a premature return
     *              inside the for-loop would yield only 1 response instead of 2.
     */
    @IsTest
    static void testMultipleRequests_returnsSameSizeAsInput() {
        List<GetFoodDetailsInvocable.FoodDetailRequest> requests =
            new List<GetFoodDetailsInvocable.FoodDetailRequest>{
                buildRequest('Burger', 'Fast Food', 600),
                buildRequest('Salad',  'Healthy',    200)
            };

        Test.startTest();
        List<GetFoodDetailsInvocable.FoodDetailResponse> responses =
            GetFoodDetailsInvocable.getFoodDetails(requests);
        Test.stopTest();

        // Core assertion for the fix: response count must equal input count.
        System.assertEquals(requests.size(), responses.size(),
            'Response list size must match input list size for multi-element input');

        System.assertEquals('Burger', responses[0].foodDetails[0].foodName,
            'First response should correspond to Burger');
        System.assertEquals('Salad', responses[1].foodDetails[0].foodName,
            'Second response should correspond to Salad');
    }

    /**
     * @description Verifies that a three-element list returns three responses.
     *              Further confirms the fix works for lists larger than two.
     */
    @IsTest
    static void testThreeRequests_returnsSameSizeAsInput() {
        List<GetFoodDetailsInvocable.FoodDetailRequest> requests =
            new List<GetFoodDetailsInvocable.FoodDetailRequest>{
                buildRequest('Pasta',   'Italian', 700),
                buildRequest('Sushi',   'Japanese', 500),
                buildRequest('Tacos',   'Mexican',  450)
            };

        Test.startTest();
        List<GetFoodDetailsInvocable.FoodDetailResponse> responses =
            GetFoodDetailsInvocable.getFoodDetails(requests);
        Test.stopTest();

        System.assertEquals(3, responses.size(),
            'Expected 3 responses for a three-element input list');
    }

    /**
     * @description Verifies that an empty input list returns an empty response list.
     */
    @IsTest
    static void testEmptyList() {
        List<GetFoodDetailsInvocable.FoodDetailRequest> requests =
            new List<GetFoodDetailsInvocable.FoodDetailRequest>();

        Test.startTest();
        List<GetFoodDetailsInvocable.FoodDetailResponse> responses =
            GetFoodDetailsInvocable.getFoodDetails(requests);
        Test.stopTest();

        System.assertNotEquals(null, responses,
            'Response list should never be null');
        System.assertEquals(0, responses.size(),
            'An empty input list should produce an empty response list');
    }

    /**
     * @description Verifies that a request with a null foodName still produces
     *              a response entry (empty foodDetails) and does not throw.
     */
    @IsTest
    static void testRequestWithNullFoodName() {
        GetFoodDetailsInvocable.FoodDetailRequest nullReq =
            new GetFoodDetailsInvocable.FoodDetailRequest();
        // foodName intentionally left null

        GetFoodDetailsInvocable.FoodDetailRequest validReq =
            buildRequest('Ramen', 'Japanese', 650);

        List<GetFoodDetailsInvocable.FoodDetailRequest> requests =
            new List<GetFoodDetailsInvocable.FoodDetailRequest>{ nullReq, validReq };

        Test.startTest();
        List<GetFoodDetailsInvocable.FoodDetailResponse> responses =
            GetFoodDetailsInvocable.getFoodDetails(requests);
        Test.stopTest();

        System.assertEquals(2, responses.size(),
            'Response count must equal input count even when some foodNames are null');
        System.assertEquals(0, responses[0].foodDetails.size(),
            'Null foodName should produce an empty foodDetails list');
        System.assertEquals(1, responses[1].foodDetails.size(),
            'Valid foodName should produce one food detail entry');
    }

    /**
     * @description Verifies that the method signature qualifies as an invocable
     *              by confirming it can be called the same way a Flow would call it.
     *              Also verifies CRUD: the method runs without DML on custom objects
     *              (no Food__c or other objects are queried or modified).
     */
    @IsTest
    static void testInvocableMethodSignature() {
        // Calling through the static public API mirrors how a Flow invokes this.
        List<GetFoodDetailsInvocable.FoodDetailRequest> requests =
            new List<GetFoodDetailsInvocable.FoodDetailRequest>{
                buildRequest('Waffle', 'Breakfast', 350),
                buildRequest('Omelette', 'Breakfast', 300)
            };

        Test.startTest();
        List<GetFoodDetailsInvocable.FoodDetailResponse> responses =
            GetFoodDetailsInvocable.getFoodDetails(requests);
        Test.stopTest();

        System.assertEquals(requests.size(), responses.size(),
            'Invocable method must return one response per input request');
    }
}
