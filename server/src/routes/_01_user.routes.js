import { Router } from "express"
import { registerUser,loginUser } from "../controller/_01_user.controller.js"
import {upload} from "../middleware/_01_multer.middle_ware.js"

const userRouter=Router()


userRouter
.route( '/register')
.post(
    upload.fields(//middle ware, before registering pls add fields called avatar and coverImage in request, so that we can access later like req.body.avatar[0].path
        [
            {
                name:"avatar",
                maxCount:1,
            },
            {
                name:"coverImage",
                maxCount:1,
            }
        ]
    ),
    registerUser
);

userRouter
.route('/login')
.post(
    loginUser,
)

   

export {userRouter}