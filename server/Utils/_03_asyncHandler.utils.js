

//we will just call this whenver we mae some APi call, so that e dont have do try catch everytime
const asyncHandler = (someCall) => async (req, res, next_middleWare_function) => {
    try {
        await someCall(req,res,next_middleWare_function);
    }catch(err){
        res.staus(
            err.code || 500 //sever error
        ).json(
            {
                success:false,
                message:err.message
            }
        )
    }
}

export {asyncHandler}