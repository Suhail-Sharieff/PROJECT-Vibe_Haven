import { asyncHandler } from "../Utils/_03_asyncHandler.utils.js";


const registerUser=asyncHandler(
    async(req,res)=>{
        const body=req.body;
        console.log(body);
        res.status(200).send(body);
    }
);

export {registerUser}