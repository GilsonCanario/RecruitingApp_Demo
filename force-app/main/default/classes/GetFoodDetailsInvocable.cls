/**
 * @description Invocable Apex class for retrieving food details from a Flow.
 *              Processes a list of FoodDetailRequest inputs and returns a list
 *              of FoodDetailResponse outputs.
 *
 *              The key correctness requirement is that the <code>return</code>
 *              statement must appear <em>after</em> the for-loop so that every
 *              element in the input list is processed before the method exits.
 */
public with sharing class GetFoodDetailsInvocable {

    /**
     * @description Retrieves food details for each request in the input list.
     *
     * @param requests List of FoodDetailRequest wrappers supplied by the Flow.
     * @return         List of FoodDetailResponse wrappers, one per input request.
     */
    @InvocableMethod(
        label='Get Food Details'
        description='Returns food details for the given food items'
        category='Food'
    )
    public static List<FoodDetailResponse> getFoodDetails(List<FoodDetailRequest> requests) {
        List<FoodDetailResponse> responses = new List<FoodDetailResponse>();

        for (FoodDetailRequest request : requests) {
            FoodDetailResponse response = new FoodDetailResponse();
            response.foodDetails = new List<FoodDetail>();

            if (request != null && request.foodName != null) {
                FoodDetail foodDetail = new FoodDetail();
                foodDetail.foodName    = request.foodName;
                foodDetail.category    = request.category;
                foodDetail.maxCalories = request.maxCalories;

                response.foodDetails.add(foodDetail);
            }

            responses.add(response);
            // NOTE: return is intentionally placed after the loop, not here,
            //       so that all elements in the list are processed.
        }

        // Return after the loop so every request is handled.
        return responses;
    }

    // -------------------------------------------------------------------------
    // Inner types
    // -------------------------------------------------------------------------

    /** @description Input wrapper for a single food-detail lookup. */
    public class FoodDetailRequest {
        @InvocableVariable(
            label='Food Name'
            description='Name of the food item to look up'
            required=true
        )
        public String foodName;

        @InvocableVariable(label='Category' description='Optional food category filter')
        public String category;

        @InvocableVariable(label='Max Calories' description='Optional calorie limit')
        public Decimal maxCalories;
    }

    /** @description Output wrapper for a single food-detail lookup. */
    public class FoodDetailResponse {
        @InvocableVariable(label='Food Details' description='Food detail records returned for this request')
        public List<FoodDetail> foodDetails;
    }

    /** @description Data-transfer object for a food item. */
    public class FoodDetail {
        @InvocableVariable(label='Food Name')
        public String foodName;

        @InvocableVariable(label='Category')
        public String category;

        @InvocableVariable(label='Max Calories')
        public Decimal maxCalories;
    }
}
